# frozen_string_literal: true

require 'test_helper'

class GymLabelTemplateTest < ActiveSupport::TestCase
  setup do
    @template = gym_label_templates(:one)
  end

  test 'validates presence of name' do
    @template.name = nil
    assert_not @template.valid?
    assert_includes @template.errors[:name], 'is_mandatory'
  end

  test 'validates inclusion of label_direction' do
    @template.label_direction = 'invalid'
    assert_not @template.valid?
    assert_includes @template.errors[:label_direction], 'is_not_a_permitted_value'
  end

  test 'validates inclusion of font_family' do
    @template.font_family = 'invalid'
    assert_not @template.valid?
    assert_includes @template.errors[:font_family], 'is_not_a_permitted_value'
  end

  test 'summary_to_json contains expected keys' do
    json = @template.summary_to_json
    assert_equal @template.id, json[:id]
    assert_equal @template.name, json[:name]
    assert_equal @template.gym.id, json[:gym][:id]
    assert json.key?(:font)
    assert json.key?(:fonts)
  end

  test 'detail_to_json contains history' do
    json = @template.detail_to_json
    assert json.key?(:history)
    assert json[:history].key?(:created_at)
    assert json[:history].key?(:updated_at)
  end

  test 'page_qr_code? returns true if footer has QrCode' do
    @template.footer_options = {
      'display' => true,
      'left' => { 'display' => false },
      'right' => { 'display' => true, 'type' => { 'QrCode' => true } }
    }
    assert @template.page_qr_code?
  end

  test 'page_qr_code? returns true if header has QrCode' do
    @template.header_options = {
      'display' => true,
      'left' => { 'display' => true, 'type' => { 'QrCode' => true } },
      'right' => { 'display' => false }
    }
    assert @template.page_qr_code?
  end

  test 'page_qr_code? returns false if no QrCode is displayed' do
    @template.footer_options = { 'display' => false }
    @template.header_options = { 'display' => false }
    assert_not @template.page_qr_code?
  end

  test 'fonts returns unique fonts used in template' do
    @template.font_family = 'lato'
    @template.label_options = {
      'grade' => { 'font_family' => 'lato' },
      'information' => { 'font_family' => 'overpass' },
      'rectangular_horizontal' => { 'height' => '27mm' }
    }
    fonts = @template.fonts
    assert_equal 2, fonts.size
    assert_includes fonts.map { |f| f[:ref] }, 'lato'
    assert_includes fonts.map { |f| f[:ref] }, 'overpass'
  end

  test 'default methods return hashes' do
    assert GymLabelTemplate.default_footer_options.is_a?(Hash)
    assert GymLabelTemplate.default_header_options.is_a?(Hash)
    assert GymLabelTemplate.default_label_options.is_a?(Hash)
    assert GymLabelTemplate.default_layout_options.is_a?(Hash)
  end

  test 'is archivable' do
    assert_respond_to @template, :archive!
    assert_respond_to @template, :unarchive!
    assert_nil @template.archived_at

    @template.archive!
    assert_not_nil @template.archived_at
    assert @template.archived?

    @template.unarchive!
    assert_nil @template.archived_at
    assert @template.unarchived?
  end
end
