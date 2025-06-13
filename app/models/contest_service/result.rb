# frozen_string_literal: true

module ContestService
  class Result
    attr_accessor :participant_by_steps, :category_by_steps, :teams

    def initialize(contest, category_id: nil, rich_data: false, by_team: false, unisex: false)
      @contest = contest
      @category_id = category_id
      @rich_data = rich_data
      @by_team = by_team
      @unisex = by_team || unisex
    end

    def results
      Rails.cache.fetch(results_cache_key, expires_in: 10.minutes) do
        build_results
      end
    end

    def delete_cache_key
      last_ascent = @contest.contest_participant_ascents.maximum(:registered_at) || 'no-ascents'
      %w[rich simple].each do |detail|
        %w[by_team by_participant].each do |team|
          %w[unisex multisex].each do |gender|
            Rails.cache.delete("contest-results-#{@contest.id}-#{last_ascent}-#{detail}-#{team}-#{gender}")
          end
        end
      end
    end

    private

    def build_results
      # init three level hash
      points_by_steps = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = Hash.new { |h3, k3| h3[k3] = [] } } }
      # init four level hash
      points_by_team_steps = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = Hash.new { |h3, k3| h3[k3] = Hash.new { |h4, k4| h4[k4] = 0 } } } }
      stages = @contest.contest_stages.includes(:contest_stage_steps).order(:stage_order)
      stage_steps = {}
      results = {}
      rankers = {}

      # Create a [Hash] participant_by_steps to determine whether the participant participates in the step.
      build_participant_by_steps

      # Create a [Hash] category_by_steps to determine whether the category participates in the step.
      build_category_by_steps

      # Build team Object
      build_teams

      # CALCULATE PARTICIPANTS SCORES
      categories.each do |category|
        participants = @contest.contest_participants
                               .includes(:contest_participant_ascents)
                               .where(contest_category: category)
        participants = participants.includes(:contest_team) if @contest.team_contest

        # For each participant
        participants.find_each do |participant|
          cat_key = build_category_key(category.unisex, category.id, participant.genre)
          participant_key = "participant-#{participant.id}"

          results[cat_key] ||= build_category_object(category, participant.genre)
          results[cat_key][:participants][participant_key] ||= build_participant_object(participant)
          results[cat_key][:teams]["team-#{participant.contest_team_id}"] ||= build_team_object(participant.contest_team) if participant.contest_team

          # For each stage (Boulder, Sport Climbing, Seep Climbing, etc.)
          stages.each do |stage|
            stage_key = "stage-#{stage.id}"
            results[cat_key][:participants][participant_key][:stages][stage_key] ||= build_stage_object(stage)
            stage_steps[stage.id] ||= stage.contest_stage_steps.order(:step_order)

            # For each step un stage (Qualification, finale, etc.)
            stage_steps[stage.id].each do |step|
              next unless category_by_steps[step.id]&.include? category.id

              rankers["#{cat_key}-#{step.id}"] ||= Ranker.new(step, category, participant.genre, force_unisex: @unisex)
              scores = rankers["#{cat_key}-#{step.id}"].participant_scores(participant.id)
              results[cat_key][:participants][participant_key][:stages][stage_key][:steps] << build_step_object(step, scores, participant)

              points_by_steps[cat_key][stage_key]["step-#{step.id}"] << scores[:value] if scores[:value]
              points_by_team_steps[cat_key][stage_key]["step-#{step.id}"][participant.contest_team_id] += scores[:value] if scores[:value] && participant.contest_team_id
            end
          end
        end
      end

      if @contest.team_contest
        # RE-MAP TEAM SCORE TO EACH PARTICIPANT STEPS
        results.each do |category_key, category|
          category[:participants].each do |_participant_key, participant|
            participant[:stages].each do |stage_key, stage|
              stage[:steps].each do |step|
                step[:team_points] += points_by_team_steps[category_key][stage_key]["step-#{step[:step_id]}"][participant[:team_id]] || 0
              end
            end
          end
        end

        # FLAT AND SORT POINTS_BY_TEAM_STEPS
        points_by_team_steps.each do |cat_key, category|
          category.each do |stage_key, stage|
            stage.each do |step_key, points|
              step_point = points.map(&:second).sort!.reverse!
              points_by_team_steps[cat_key][stage_key][step_key] = step_point
            end
          end
        end
      end

      # SORT HASH POINT_BY_STEPS
      # (and give ordre of point)
      points_by_steps.each do |cat_key, category|
        category.each do |stage_key, stage|
          stage.each do |step_key, _points|
            points_by_steps[cat_key][stage_key][step_key].sort!.reverse!
          end
        end
      end

      # Normalize results array and set step rank
      results = results.map(&:last)
      results.each_with_index do |rlt_category, category_index|
        # Set maximum rank possible in category : is number of teams, or number of participants
        if @contest.team_contest && @by_team
          max_rank = rlt_category[:teams].size
          rank_key = :team_rank
        else
          max_rank = rlt_category[:participants].size
          rank_key = :rank
        end

        rlt_category[:participants] = results[category_index][:participants].map(&:last)
        rlt_category[:participants].each do |rlt_participant|
          ranks = []
          team_ranks = []
          rlt_participant[:stages] = rlt_participant[:stages].map(&:last)
          rlt_participant[:stages].each do |rlt_stage|
            rlt_stage[:steps].each do |rlt_step|
              cat_key = build_category_key(rlt_category[:unisex], rlt_category[:category_id], rlt_category[:genre])
              rank = points_by_steps[cat_key]["stage-#{rlt_stage[:stage_id]}"]["step-#{rlt_step[:step_id]}"].find_index(rlt_step[:points])
              rank += 1 if rank
              ranks.unshift rank
              rlt_step[:rank] = rank
              next unless @contest.team_contest

              team_rank = points_by_team_steps[cat_key]["stage-#{rlt_stage[:stage_id]}"]["step-#{rlt_step[:step_id]}"].find_index(rlt_step[:team_points])
              team_rank += 1 if team_rank
              team_ranks.unshift team_rank
              rlt_step[:team_rank] = team_rank
            end
          end
          rlt_participant[:ranks] = ranks
          rlt_participant[:team_ranks] = team_ranks if @contest.team_contest

          # Get last rank of each step for first sort
          ranks = []
          rlt_participant[:stages].each do |rlt_stage|
            last_step_rank = rlt_stage[:steps].map { |step| step[rank_key] }.last
            rank_decimal = ''
            rlt_stage[:steps].map { |step| step[rank_key] }
                             .reverse
                             .each_with_index do |rank, rank_index|
              next if rank_index.zero?

              rank_decimal = "#{rank_decimal}#{(rank || max_rank).to_s.rjust(max_rank.to_s.size, '0')}"
            end
            rank_decimal = "#{last_step_rank || max_rank}.#{rank_decimal}".to_f
            rlt_stage[:stage_rank] = rank_decimal
            ranks << rank_decimal
          end

          # Calculate global rank points
          case @contest.combined_ranking_type
          when Constant::COMBINED_RANKING_ADDITION
            rank_point = 0
            ranks.each do |rank|
              rank_point += rank || max_rank
            end
          when Constant::COMBINED_RANKING_MULTIPLICATION
            rank_point = 1
            ranks.each do |rank|
              rank_point *= rank || max_rank
            end
          when Constant::COMBINED_RANKING_DECREMENT_POINTS
            rank_point = 0
            ranks.each do |rank|
              rank_point += if rank.blank?
                              0
                            elsif rank <= 30
                              Constant::COMBINED_RANKING_POINT_MATRIX[rank.to_i - 1].to_f
                            else
                              1.0 - (1.0 / (max_rank - 29)) * (rank - 29)
                            end
            end
          else
            rank_point = 0
            ranks.each do |rank|
              rank_point += rank || max_rank
            end
          end

          rlt_participant[:global_rank_point] = rank_point
        end

        # Sort participant by global rank point
        results[category_index][:participants] = if @contest.combined_ranking_type == Constant::COMBINED_RANKING_DECREMENT_POINTS
                                                   results[category_index][:participants].sort_by { |participant| -participant[:global_rank_point] }
                                                 else
                                                   results[category_index][:participants].sort_by { |participant| participant[:global_rank_point] }
                                                 end

        # Create global rank index
        rank_index = 0
        results[category_index][:participants].each_with_index do |participant, index|
          same_team = false
          equality = index.positive? && results[category_index][:participants][index - 1][:global_rank_point] == participant[:global_rank_point]
          if index.positive? && @contest.team_contest && @by_team
            previous_team = results[category_index][:participants][index - 1][:team_id]
            current_team = results[category_index][:participants][index][:team_id]
            same_team = previous_team == current_team && current_team.present?
          end
          rank_index += 1 unless same_team
          global_rank = if equality || same_team
                          results[category_index][:participants][index - 1][:global_rank]
                        else
                          rank_index
                        end
          results[category_index][:participants][index][:global_rank] = global_rank
          results[category_index][:participants][index][:same_team] = same_team
        end
      end
    end

    # -----------------
    # QUERIES SELECTORS
    # -----------------

    # Create participant by steps Hash :
    # @return [Hash], example : { step_id => [ participant_id, participant_id, participant_id] }
    def build_participant_by_steps
      self.participant_by_steps = Hash.new { |hash, key| hash[key] = [] }
      steps = ContestParticipantStep.select(%i[id contest_stage_step_id contest_participant_id])
                                    .joins(contest_stage_step: :contest_stage)
                                    .where(contest_stages: { contest_id: @contest.id })
      steps.each do |participant_step|
        participant_by_steps[participant_step.contest_stage_step_id] << participant_step.contest_participant_id
      end
    end

    # Create category by steps Hash :
    # @return [Hash], example : { step_id => [ contest_category_id, contest_category_id, contest_category_id] }
    def build_category_by_steps
      self.category_by_steps = Hash.new { |hash, key| hash[key] = [] }
      group_categories = ContestRouteGroupCategory.select('contest_stage_steps.id AS contest_stage_step_id, contest_route_group_categories.contest_category_id')
                                                  .joins(contest_route_group: { contest_stage_step: :contest_stage })
                                                  .where(contest_stages: { contest_id: @contest.id })
      group_categories.each do |group_category|
        category_by_steps[group_category['contest_stage_step_id']] << group_category.contest_category_id
      end
    end

    # Select Contest Categories
    # @return [Array]
    def categories
      @category_id.present? ? @contest.contest_categories.where(id: @category_id) : @contest.contest_categories
    end

    # Create unique key for results hash
    # @return [String], example : category-2-female
    def build_category_key(unisex, category_id, genre)
      if @by_team
        "category-#{category_id}"
      else
        unisex || @unisex ? "category-#{category_id}" : "category-#{category_id}-#{genre}"
      end
    end

    # Create key for result cache
    # @return [String]
    def results_cache_key
      rich_key = @rich_data ? 'rich' : 'simple'
      by_team_key = @by_team ? 'by_team' : 'by_participant'
      unisex = @unisex ? 'unisex' : 'multisex'
      last_ascent = @contest.contest_participant_ascents.maximum(:registered_at) || 'no-ascents'
      "contest-results-#{@contest.id}-#{last_ascent}-#{rich_key}-#{by_team_key}-#{unisex}"
    end

    # Create global results Object
    # @return [Hash]
    def build_category_object(category, genre)
      {
        category_name: category.name,
        category_id: category.id,
        unisex: category.unisex == true,
        genre: genre,
        order: category.order,
        participants: {},
        teams: {}
      }
    end

    # ----------------
    # OBJECTS BUILDERS
    # ----------------

    # Create team for time size
    # @return [Hash]
    def build_teams
      self.teams = {}
      @contest.contest_teams.includes(:contest_participants).each do |team|
        teams[team.id] = {
          id: team.id,
          name: team.name,
          number_of_participants: team.contest_participants.size
        }
      end
    end

    # Create initial participant object
    # @return [Hash]
    def build_participant_object(participant)
      data = {
        global_rank: nil,
        global_rank_point: nil,
        ranks: [],
        participant_id: participant.id,
        first_name: participant.first_name,
        last_name: participant.last_name,
        affiliation: participant.affiliation,
        stages: {}
      }
      if @contest.team_contest
        data[:team_id] = participant.contest_team&.id
        data[:team_name] = participant.contest_team&.name
        data[:team_size] = participant.contest_team_id.present? ? teams[participant.contest_team_id][:number_of_participants] : 1
        data[:team_global_rank] = nil
        data[:team_global_rank_point] = 0
      end
      if @rich_data
        data[:email] = participant.email
        data[:date_of_birth] = participant.date_of_birth
      end
      data
    end

    # Create team object
    # @return [Hash]
    def build_team_object(team)
      {
        id: team.id,
        name: team.name
      }
    end

    # Create stage object
    # @return [Hash]
    def build_stage_object(stage)
      {
        stage_id: stage.id,
        climbing_type: stage.climbing_type,
        stage_name: stage.name,
        stage_rank: nil,
        steps: []
      }
    end

    # Create step object
    # @return [Hash]
    def build_step_object(step, scores, participant)
      {
        step_id: step.id,
        step_order: step.step_order,
        name: step.name,
        participant_for_next_step: step.default_participants_for_next_step,
        subscribe: participant_by_steps[step.id]&.include?(participant.id),
        rank: nil,
        index: nil,
        points: scores[:value],
        score_details: scores[:details],
        unit_details: scores[:units],
        team_rank: nil,
        team_index: nil,
        team_points: 0
      }
    end
  end
end
