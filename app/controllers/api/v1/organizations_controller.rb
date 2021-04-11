# frozen_string_literal: true

module Api
  module V1
    class OrganizationsController < ApiController
      before_action :protected_by_session
      before_action :set_organization, except: %i[create index]
      before_action :protected_by_owner, except: %i[create index]

      def index
        @organizations = User.current.organizations
      end

      def show; end

      def api_access_token
        render json: { api_access_token: @organization.api_access_token }
      end

      def create
        @organization = Organization.new organization_params
        @organization.organization_users << OrganizationUser.new(user: User.current)
        if @organization.save
          render 'api/v1/organizations/show'
        else
          render json: { error: @organization.errors }, status: :unprocessable_entity
        end
      end

      def refresh_api_access_token
        @organization.refresh_api_access_token!
        render json: { api_access_token: @organization.api_access_token }
      end

      def update
        if @organization.update(organization_params)
          render 'api/v1/organizations/show'
        else
          render json: { error: @organization.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_organization
        @organization = Organization.find params[:id]
      end

      def protected_by_owner
        not_authorized unless @organization.users.include?(User.current)
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
