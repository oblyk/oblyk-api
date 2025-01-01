# frozen_string_literal: true

class Championship < ApplicationRecord
  include Slugable
  include AttachmentResizable
  include StripTagable
  include Archivable

  has_one_attached :banner
  belongs_to :gym

  has_many :championship_contests, dependent: :destroy
  has_many :contests, through: :championship_contests
  has_many :championship_categories, dependent: :destroy
  has_many :championship_category_matches, through: :championship_categories

  before_validation :normalize_attributes

  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :combined_ranking_type, inclusion: { in: ContestRanking::COMBINED_RANKING_TYPE_LIST }, allow_nil: :nil
  validates :name, presence: true

  def banner_large_url
    resize_attachment banner, '1920x1920'
  end

  def banner_thumbnail_url
    resize_attachment banner, '300x300'
  end

  def results
    return nil if championship_category_matches.blank?
    return nil if contests.blank?

    championship_results = {}
    championship_categories.each do |championship_category|
      %w[male female].each do |genre|
        key = "#{championship_category.id}-#{genre}"
        championship_results[key] ||= {
          genre: genre,
          category_id: championship_category.id,
          category_name: championship_category.name,
          matches_contest_categories: championship_category.championship_category_matches.pluck(:contest_category_id),
          participants: {}
        }
      end
    end

    last_ranks = []
    all_contest_results = []
    contests.order(:start_date).each do |contest|
      results = contest.results(nil, true)
      results.each do |category|
        championship_results.each do |_k, v|
          next unless v[:matches_contest_categories].include?(category[:category_id]) && v[:genre] == category[:genre]

          last_ranks << { contest_id: contest.id, championship_category_id: v[:category_id], genre: v[:genre], last_rank: category[:participants].last[:global_rank] }
        end
      end
      all_contest_results << {
        contest: contest,
        contest_results: results
      }
    end

    # Create participant table and rank by contest
    all_contest_results.each do |contest_results|
      contest_results[:contest_results].each do |category|
        next unless championship_category_matches.pluck(:contest_category_id).include?(category[:category_id])

        # Find matches key form contest category to championship category
        results_key = nil
        championship_results.each do |k, v|
          next unless v[:matches_contest_categories].include?(category[:category_id]) && v[:genre] == category[:genre]

          results_key = k
          break
        end

        category[:participants].each do |participant|
          participant_key = "#{participant[:first_name]}-#{participant[:last_name]}-#{participant[:date_of_birth]}".parameterize
          unless championship_results[results_key][:participants][participant_key]
            filtered_contests = last_ranks.filter do |last_rank|
              last_rank[:championship_category_id] == championship_results[results_key][:category_id] && last_rank[:genre] == category[:genre]
            end
            last_rank_contests = {}
            filtered_contests.each do |filtered_contest|
              last_rank_contests[filtered_contest[:contest_id]] = { rank: filtered_contest[:last_rank], present: false, contest_id: filtered_contest[:contest_id] }
            end
            championship_results[results_key][:participants][participant_key] = {
              first_name: participant[:first_name],
              last_name: participant[:last_name],
              global_rank: nil,
              rank_point: nil,
              contests: last_rank_contests
            }
          end
          championship_results[results_key][:participants][participant_key][:contests][contest_results[:contest].id] = { rank: participant[:global_rank], present: true, contest_id: contest_results[:contest].id }
        end
      end
    end

    # Delete working key
    championship_results = championship_results.map(&:second)
    max_number_of_participant = 0
    championship_results.each do |championship_result|
      max_number_of_participant = championship_result[:participants].size if championship_result[:participants].size > max_number_of_participant
    end

    # Calculate global rank
    championship_results.each_with_index do |_championship_result, index|
      championship_results[index][:participants] = championship_results[index][:participants].map(&:second)
      number_of_participant = championship_results[index][:participants].size
      championship_results[index][:participants].each_with_index do |participant, participant_index|
        case combined_ranking_type
        when ContestRanking::COMBINED_RANKING_ADDITION
          rank_point = 0
          participant[:contests].each do |_k, v|
            rank_point += v[:present] ? v[:rank] : max_number_of_participant
          end
        when ContestRanking::COMBINED_RANKING_MULTIPLICATION
          rank_point = 1
          participant[:contests].each do |_k, v|
            rank_point *= v[:present] ? v[:rank] : max_number_of_participant
          end
        when ContestRanking::COMBINED_RANKING_DECREMENT_POINTS
          rank_point = 0
          participant[:contests].each do |_k, v|
            rank_point += if !v[:present]
                            0
                          elsif v[:rank] <= 30
                            ContestRanking::COMBINED_RANKING_POINT_MATRIX[v[:rank] - 1]
                          else
                            1.0 - (1.0 / (number_of_participant - 29)) * (v[:rank] - 29)
                          end
          end
        else
          rank_point = 0
          participant[:contests].each do |_k, v|
            rank_point += v[:present] ? v[:rank] : max_number_of_participant
          end
        end

        championship_results[index][:participants][participant_index][:rank_point] = rank_point
      end

      # Sort participant by global rank point
      championship_results[index][:participants] = if combined_ranking_type == ContestRanking::COMBINED_RANKING_DECREMENT_POINTS
                                                     championship_results[index][:participants].sort_by { |participant| -participant[:rank_point] }
                                                   else
                                                     championship_results[index][:participants].sort_by { |participant| participant[:rank_point] }
                                                   end

      # Create global rank index
      championship_results[index][:participants].each_with_index do |participant, final_index|
        global_rank = if final_index.positive? && championship_results[index][:participants][final_index - 1][:rank_point] == participant[:rank_point]
                        championship_results[index][:participants][final_index - 1][:global_rank]
                      else
                        final_index + 1
                      end
        championship_results[index][:participants][final_index][:global_rank] = global_rank
      end
    end

    {
      championship_results: championship_results,
      contests: contests.order(:start_date).map(&:summary_to_json)
    }
  end

  def summary_to_json
    data = Rails.cache.fetch("#{cache_key_with_version}/summary_championship", expires_in: 28.days) do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        description: description,
        gym_id: gym_id,
        combined_ranking_type: combined_ranking_type,
        banner: banner.attached? ? banner_large_url : nil, # TODO: must be deleted
        banner_thumbnail_url: banner.attached? ? banner_thumbnail_url : nil, # TODO: must be deleted
        archived_at: archived_at,
        attachments: {
          banner: attachment_object(banner)
        },
        gym: {
          id: gym.id,
          name: gym.name,
          slug_name: gym.slug_name
        }
      }
    end
    data[:contests_count] = contests.count
    data
  end

  def detail_to_json
    summary_to_json.merge(
      {
        gym: gym.summary_to_json,
        contests: contests.map(&:summary_to_json),
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_championship")
  end

  private

  def normalize_attributes
    self.description = description&.strip
    self.description = nil if description.blank?

    self.combined_ranking_type ||= ContestRanking::COMBINED_RANKING_ADDITION
  end
end
