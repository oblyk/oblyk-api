# frozen_string_literal: true

require 'test_helper'

class PointsToSvgTest < ActiveSupport::TestCase
  test 'initialize with default values' do
    points = [{ id: 1, points: [{ x: 0, y: 0 }, { x: 10, y: 10 }] }]
    converter = PointsToSvg.new(points)

    assert_equal points, converter.points
    assert_equal 800, converter.width
    assert_equal 800, converter.height
    assert_equal 1.2, converter.padding
    assert_equal 40, converter.circle_radius
  end

  test 'initialize with custom values' do
    points = [{ id: 1, points: [{ x: 0, y: 0 }] }]
    converter = PointsToSvg.new(points, width: 400, height: 300, padding: 2.0, circle_radius: 10)

    assert_equal 400, converter.width
    assert_equal 300, converter.height
    assert_equal 2.0, converter.padding
    assert_equal 10, converter.circle_radius
  end

  test 'svg_file returns nil if points are empty' do
    converter = PointsToSvg.new([])
    assert_nil converter.svg_file
  end

  test 'svg_file returns nil if all points groups are empty' do
    converter = PointsToSvg.new([{ id: 1, points: [] }])
    assert_nil converter.svg_file
  end

  test 'svg_file generates valid svg string' do
    points = [
      {
        id: 'shape-1',
        points: [
          { x: 0, y: 0 },
          { x: 10, y: 0 },
          { x: 5, y: 10 }
        ]
      }
    ]
    converter = PointsToSvg.new(points, width: 100, height: 100, padding: 0)
    svg = converter.svg_file

    assert_match(/<svg xmlns='http:\/\/www.w3.org\/2000\/svg' width='100' height='100' viewBox='0 0 100 100'>/, svg)
    assert_match(/<polygon id='shape-1' points='.*' \/>/, svg)
    assert_match(/<circle id='shape-1' cx='.*' cy='.*' r='40' \/>/, svg)
  end

  test 'svg_file handles multiple shapes' do
    points = [
      { id: '1', points: [{ x: 0, y: 0 }, { x: 1, y: 1 }] },
      { id: '2', points: [{ x: 2, y: 2 }, { x: 3, y: 3 }] }
    ]
    converter = PointsToSvg.new(points)
    svg = converter.svg_file

    assert_match(/id='1'/, svg)
    assert_match(/id='2'/, svg)
    assert_equal 2, svg.scan(/<polygon/).size
    assert_equal 2, svg.scan(/<circle/).size
  end
end
