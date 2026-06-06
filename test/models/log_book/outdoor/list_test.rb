# frozen_string_literal: true

require 'test_helper'

module LogBook
  module Outdoor
    class ListTest < ActiveSupport::TestCase
      setup do
        @user = users(:normal_user)
        @ascents = @user.ascent_crag_routes
        @list = List.new(@ascents)
      end

      test 'ascended_crag_routes returns an array' do
        # On utilise une page et un ordre par défaut
        result = @list.ascended_crag_routes(1, 'released_at')
        assert_kind_of Array, result
      end
      
      test 'ascended_crag_routes handles different orders' do
        assert_kind_of Array, @list.ascended_crag_routes(1, 'crags')
        assert_kind_of Array, @list.ascended_crag_routes(1, 'grade')
      end
    end
  end
end
