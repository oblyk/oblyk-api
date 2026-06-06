# frozen_string_literal: true

require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  setup do
    @link = links(:link_1)
  end

  test 'is valid' do
    assert @link.valid?
  end

  test 'is invalid if it has no name' do
    @link.name = nil
    assert_not @link.valid?
  end

  test 'is invalid if it has no url' do
    @link.url = nil
    assert_not @link.valid?
  end

  test 'is invalid if linkable_type is not in the list' do
    @link.linkable_type = 'User'
    assert_not @link.valid?
  end

  test 'is valid with allowed linkable_types' do
    types = {
      'Crag' => crags(:orpierre),
      'CragSector' => crag_sectors(:sector_one),
      'CragRoute' => crag_routes(:route_one),
      'GuideBookPaper' => guide_book_papers(:guide_book_2024),
      'Area' => areas(:foret_de_saou)
    }

    types.each do |type, record|
      @link.linkable = record
      assert @link.valid?, "#{type} should be a valid linkable_type, errors: #{@link.errors.full_messages}"
    end
  end

  test 'detail_to_json returns the correct format' do
    @link.description = 'A description'
    json = @link.detail_to_json
    assert_equal @link.id, json[:id]
    assert_equal @link.name, json[:name]
    assert_equal @link.url, json[:url]
    assert_equal 'A description', json[:description]
    assert json.key?(:creator)
    assert json.key?(:history)
  end
end
