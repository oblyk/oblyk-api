# frozen_string_literal: true

require 'test_helper'

class SlugableTest < ActiveSupport::TestCase
  test 'init_slug_name sets slug_name from name' do
    crag = Crag.new(name: 'Super Falaise')
    crag.valid?
    assert_equal 'super-falaise', crag.slug_name
  end

  test 'init_slug_name does not overwrite existing slug_name' do
    crag = Crag.new(name: 'Super Falaise', slug_name: 'custom-slug')
    crag.valid?
    assert_equal 'custom-slug', crag.slug_name
  end

  test 'init_slug_name fallback to class name if name is empty' do
    crag = Crag.new(name: '')
    crag.valid?
    assert_equal 'crag', crag.slug_name
  end
end
