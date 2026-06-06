# frozen_string_literal: true

require 'test_helper'

class DiscChartServiceTest < ActiveSupport::TestCase
  setup do
    @routes = [
      {
        sheet_reference: 1,
        hold_colors: ['#ff0000'],
        grade_to_s: '6a',
        openers: [{ name: 'Alice' }],
        qr_svg: '<svg viewBox="0 0 10 10"><rect width="10" height="10"/></svg>'
      },
      {
        sheet_reference: 1,
        hold_colors: %w[#0000ff #ffffff],
        grade_to_s: '6b',
        openers: [{ name: 'Bob' }, { name: 'Charlie' }],
        qr_svg: '<svg viewBox="0 0 10 10"><rect width="10" height="10"/></svg>'
      }
    ]
    @service = DiscChartService.new(@routes)
  end

  test 'should initialize with correct attributes and defaults' do
    assert_equal @routes, @service.instance_variable_get(:@routes)
    assert_equal DiscChartService::RADIUS, @service.instance_variable_get(:@radius)
    assert_equal DiscChartService::TITLE_FS, @service.instance_variable_get(:@title_fs)
    assert_equal DiscChartService::GRADE_FS, @service.instance_variable_get(:@grade_fs)
    assert_equal DiscChartService::SETTER_FS, @service.instance_variable_get(:@setter_fs)
  end

  test 'should allow overriding defaults in initialize' do
    service = DiscChartService.new(@routes, radius: 100, title_fs: 20)
    assert_equal 100, service.instance_variable_get(:@radius)
    assert_equal 20, service.instance_variable_get(:@title_fs)
  end

  test 'dark_color? identifies dark and light colors correctly' do
    assert @service.send(:dark_color?, '#000000') # Black
    assert @service.send(:dark_color?, '#ff0000') # Red (perceived dark in this formula)
    assert_not @service.send(:dark_color?, '#ffffff') # White
    assert_not @service.send(:dark_color?, '#ffff00') # Yellow
  end

  test 'interpolate_middle_color calculates middle color' do
    # Single color
    assert_equal '#ff0000', @service.send(:interpolate_middle_color, ['#ff0000'])
    # Two colors (middle of #ff0000 and #000000 is #800000)
    assert_equal '#800000', @service.send(:interpolate_middle_color, ['#ff0000', '#000000'])
  end

  test 'text_color_for returns white for dark backgrounds and black for light' do
    assert_equal 'white', @service.send(:text_color_for, ['#000000'])
    assert_equal 'black', @service.send(:text_color_for, ['#ffffff'])
  end

  test 'openers_to_s formats names correctly' do
    assert_equal '', @service.send(:openers_to_s, [])
    assert_equal 'Alice', @service.send(:openers_to_s, [{ name: 'Alice' }])
    assert_equal 'Alice / Bob', @service.send(:openers_to_s, [{ name: 'Alice' }, { name: 'Bob' }])
    assert_equal 'Alice, Bob / Charlie', @service.send(:openers_to_s, [{ name: 'Alice' }, { name: 'Bob' }, { name: 'Charlie' }])
  end

  test 'generate_svg_for_relay generates valid SVG for single route' do
    single_route_group = [@routes[0]]
    svg = @service.send(:generate_svg_for_relay, 1, single_route_group)

    assert_match(/<svg/, svg)
    assert_match(/Relais n°1/, svg)
    assert_match(/6a/, svg)
    assert_match(/Alice/, svg)
    assert_match(/<circle/, svg) # Single route uses a circle
  end

  test 'generate_svg_for_relay generates valid SVG for multi routes' do
    svg = @service.send(:generate_svg_for_relay, 1, @routes)

    assert_match(/<svg/, svg)
    assert_match(/Relais n°1/, svg)
    assert_match(/6a/, svg)
    assert_match(/6b/, svg)
    assert_match(/Alice/, svg)
    assert_match(/Bob \/ Charlie/, svg)
    assert_match(/<path/, svg) # Multi route uses paths for wedges
    assert_match(/linearGradient id="grad_1_1"/, svg) # Check gradient for the second route
  end

  test 'generate_svg_for_relay handles routes without QR codes' do
    # Pour une seule route sans QR
    route = {
      sheet_reference: 1,
      hold_colors: ['#ff0000'],
      grade_to_s: '6a',
      openers: [{ name: 'Alice' }]
    }
    service = DiscChartService.new([route])
    svg = service.send(:generate_svg_for_relay, 1, [route])

    assert_match(/6a/, svg)
    assert_match(/Alice/, svg)
    assert_no_match(/<rect [^>]*fill="white" [^>]*stroke="black" [^>]*stroke-width="0.5"/, svg)
  end

  test 'generate_pdf returns a StringIO containing PDF data' do
    # Since we use Prawn and SVG, this is more of an integration test
    result = @service.generate_pdf

    assert_kind_of StringIO, result
    # PDF magic number
    assert result.string.start_with?('%PDF-')
  end
end
