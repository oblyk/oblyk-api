# frozen_string_literal: true

require 'test_helper'

class HistorizeTownJobTest < ActiveJob::TestCase
  setup do
    @town = towns(:valence)
  end

  test 'it calls historize! on the town' do
    mock = Minitest::Mock.new
    mock.expect :historize!, true

    Town.stub :find, mock do
      HistorizeTownJob.perform_now(@town.id)
    end

    assert_mock mock
  end

  test 'it historizes the town correctly' do
    # On supprime les éventuels objets existants pour tester la création
    TownJsonObject.where(town: @town).destroy_all

    assert_difference 'TownJsonObject.count', 1 do
      HistorizeTownJob.perform_now(@town.id)
    end

    town_json_object = TownJsonObject.last
    assert_equal @town.id, town_json_object.town_id
    assert_not_nil town_json_object.json_object
  end
  test 'it raises error if town does not exist' do
    assert_raises(ActiveRecord::RecordNotFound) do
      HistorizeTownJob.perform_now(0)
    end
  end
end
