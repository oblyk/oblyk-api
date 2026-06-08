# frozen_string_literal: true

require 'test_helper'

module LogBook
  module Outdoor
    class FigureTest < ActiveSupport::TestCase
      setup do
        @ascent1 = ascent_crag_routes(:crag_ascent_one)
        @ascent2 = ascent_crag_routes(:crag_ascent_project)
        @ascents = [@ascent1, @ascent2]
        @figure = Figure.new(@ascents)
      end

      test 'figures returns correct keys' do
        figs = @figure.figures
        assert_includes figs.keys, :countries
        assert_includes figs.keys, :regions
        assert_includes figs.keys, :crags
        assert_includes figs.keys, :ascents
        assert_includes figs.keys, :meters
        assert_includes figs.keys, :max_grade_value
      end

      test 'ascents_count returns correct count' do
        assert_equal 2, @figure.send(:ascents_count)
      end

      test 'sum_meters handles nil height' do
        @ascent1.stub :sections, [] do
          @ascent1.stub :height, nil do
            @ascent2.stub :sections, [] do
              @ascent2.stub :height, 10 do
                assert_equal 10, @figure.send(:sum_meters)
              end
            end
          end
        end
      end
    end
  end
end
