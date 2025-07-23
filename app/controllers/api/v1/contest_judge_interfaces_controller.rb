# frozen_string_literal: true

module Api
  module V1
    class ContestJudgeInterfacesController < ApiController
      before_action :set_gym
      before_action :set_contest
      before_action :set_contest_judge
      before_action :verify_contest_judge_access, only: %i[participants]

      def show
        judge_data = {
          name: @contest_judge.name,
          contest_route_ids: @contest_judge.contest_routes.pluck(:id)
        }
        contest_data = {
          name: @contest.name,
          id: @contest.id,
          gym_id: @contest.gym_id,
          attachments: {
            banner: @contest.attachment_object(@contest.banner)
          }
        }
        render json: { contest_judge: judge_data, contest: contest_data }, status: :ok
      end

      def unlock
        unlocked = @contest_judge.code == params[:contest_judge][:code]
        token = nil
        if unlocked
          exp = Time.zone.tomorrow.end_of_day.to_i
          token = JwtToken::Token.generate({ judge_id: @contest_judge.id, code: @contest_judge.code }, exp)
        end
        render json: {
          unlocked: @contest_judge.code == params[:contest_judge][:code],
          token: token
        }, status: :ok
      end

      def participants
        participant_ids = @contest_judge.contest_routes
                                        .select('DISTINCT contest_participants.id AS participant_id')
                                        .joins(contest_route_group: { contest_route_group_categories: { contest_category: :contest_participants } })
                                        .joins('INNER JOIN contest_participant_steps ON contest_participants.id = contest_participant_steps.contest_participant_id AND contest_route_groups.contest_stage_step_id = contest_participant_steps.contest_stage_step_id')
                                        .where("contest_route_groups.genre_type = 'unisex' OR contest_route_groups.genre_type = contest_participants.genre")
                                        .reorder(1)
        participants = ContestParticipant.where(id: participant_ids.map(&:participant_id))
        render json: participants.map(&:summary_to_json), status: :ok
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]
      end

      def set_contest
        @contest = @gym.contests.find params[:contest_id]
      end

      def set_contest_judge
        @contest_judge = @contest.contest_judges.includes(contest_judge_routes: :contest_route).find_by(uuid: params[:id])
      end

      def verify_contest_judge_access
        token = JwtToken::Token.decode(request.headers['HttpContestJudgeToken']).try(:[], 'data')
        judge = @contest.contest_judges.find_by(id: token['judge_id'], code: token['code'])

        return if judge

        render json: {}, status: 419
      end
    end
  end
end
