# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < ApiController
      before_action :protected_by_session
      before_action :set_organization, except: %i[create index]
      before_action :protected_by_owner, except: %i[create index]

      def index
        organizations = User.current.organizations
        render json: organizations.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @organization.detail_to_json, status: :ok
      end

      def api_access_token
        render json: { api_access_token: @organization.api_access_token }, status: :ok
      end

      def create
        @organization = Organization.new organization_params
        @organization.organization_users << OrganizationUser.new(user: User.current)
        if @organization.save
          render json: @organization.detail_to_json, status: :ok
        else
          render json: { error: @organization.errors }, status: :unprocessable_entity
        end
      end

      def refresh_api_access_token
        @organization.refresh_api_access_token!
        render json: { api_access_token: @organization.api_access_token }, status: :ok
      end

      def update
        if @organization.update(organization_params)
          render json: @organization.detail_to_json, status: :ok
        else
          render json: { error: @organization.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @organization.destroy
        head :no_content
      end

      private

      def set_organization
        @organization = Organization.find params[:id]
      end

      def protected_by_owner
        forbidden unless @organization.users.include?(User.current)
      end

      def organization_params
        params.require(:organization).permit(
          :name,
          :api_usage_type,
          :phone,
          :email,
          :address,
          :city,
          :zipcode,
          :website,
          :website,
          :company_registration_number
        )
      end
    end
  end
end
