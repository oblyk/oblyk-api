# frozen_string_literal: true

module Api
  module V1
    class ReportsController < ApiController
      before_action :protected_by_session, only: %i[create]

      def create
        report = Report.new(report_params)
        report.reportable_type ||= 'Organization'
        report.reportable_id ||= Organization.current.id
        report.user = @current_user
        if report.save
          render json: {}, status: :ok
        else
          render json: { error: report.errors }, status: :unprocessable_entity
        end
      end

      private

      def report_params
        params.require(:report).permit(
          :reportable_type,
          :reportable_id,
          :report_from_url,
          :body
        )
      end
    end
  end
end
