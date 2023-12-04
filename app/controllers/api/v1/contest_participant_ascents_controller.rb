# frozen_string_literal: true

module Api
  module V1
    class ContestParticipantAscentsController < ApiController
      before_action :set_contest
      before_action :set_contest_participant

      def create
        contest_ascent = ContestParticipantAscent.find_or_initialize_by(
          contest_participant_id: @contest_participant.id,
          contest_route_id: params[:contest_participant_ascent][:contest_route_id]
        )
        contest_ascent.realised = contest_participant_params[:realised]
        contest_ascent.zone_1_attempt = contest_participant_params[:zone_1_attempt]
        contest_ascent.zone_2_attempt = contest_participant_params[:zone_2_attempt]
        contest_ascent.top_attempt = contest_participant_params[:top_attempt]
        contest_ascent.hold_number = contest_participant_params[:hold_number]
        contest_ascent.hold_number_plus = contest_participant_params[:hold_number_plus]

        if contest_ascent.save
          head :no_content
        else
          render json: { error: contest_ascent.errors }, status: :unprocessable_entity
        end
      end

      def bulk
        errors = []
        bulk_contest_ascents_params[:ascents].each do |ascent|
          contest_ascent = ContestParticipantAscent.find_or_initialize_by(
            contest_participant_id: @contest_participant.id,
            contest_route_id: ascent[:contest_route_id]
          )
          contest_ascent.realised = ascent[:realised]
          contest_ascent.zone_1_attempt = ascent[:zone_1_attempt]
          contest_ascent.zone_2_attempt = ascent[:zone_2_attempt]
          contest_ascent.top_attempt = ascent[:top_attempt]
          contest_ascent.hold_number = ascent[:hold_number]
          contest_ascent.hold_number_plus = ascent[:hold_number_plus]

          errors << contest_ascent.errors.full_messages unless contest_ascent.save
        end

        if errors.size.zero?
          head :no_content
        else
          render json: { error: errors }, status: :unprocessable_entity
        end
      end

      private

      def set_contest
        @contest = Contest.where(gym_id: params[:gym_id]).find params[:contest_id]
      end

      def set_contest_participant
        token = params[:contest_participant_ascent][:contest_participant_token]
        @contest_participant = @contest.contest_participants.find_by token: token
      end

      def contest_participant_params
        params.require(:contest_participant_ascent).permit(
          :realised,
          :zone_1_attempt,
          :zone_2_attempt,
          :top_attempt,
          :hold_number,
          :hold_number_plus
        )
      end

      def bulk_contest_ascents_params
        params.require(:contest_participant_ascent).permit(
          :gym_id,
          :contest_participant_token,
          :contest_id,
          ascents: %i[contest_id
                      contest_participant_token
                      contest_route_id
                      gym_id
                      realised
                      zone_1_attempt
                      zone_2_attempt
                      top_attempt
                      hold_number
                      hold_number_plus]
        )
      end
    end
  end
end
