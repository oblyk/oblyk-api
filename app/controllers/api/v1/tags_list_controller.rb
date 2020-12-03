# frozen_string_literal: true

module Api
  module V1
    class TagsListController < ApiController
      def index
        render json: Tag::TAGS_LIST
      end
    end
  end
end
