# frozen_string_literal: true

require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  setup do
    @crag = crags(:orpierre)
    ENV['SEARCH_INGESTABLE'] = 'true'
  end

  teardown do
    ENV['SEARCH_INGESTABLE'] = 'false'
  end

  test 'search_push is called after save' do
    Search.stub :push, ->(value, id, class_name, bucket, secondary_bucket) { @pushed = true } do
      @crag.name = 'New Name'
      @crag.save
      assert @pushed
    end
  end

  test 'search_destroy is called after destroy' do
    word = words(:with_fingers)
    Search.stub :delete_object, ->(class_name, id) { @deleted = true } do
      word.destroy
      assert @deleted
    end
  end

  test 'search method calls Search.search' do
    Search.stub :search, [@crag.id] do
      results = Crag.search('orpierre')
      assert_includes results, @crag
    end
  end

  test 'refresh_search_index calls search_push with force true' do
    Search.stub :push, ->(value, id, class_name, bucket, secondary_bucket) { @pushed = true } do
      @crag.refresh_search_index
      assert @pushed
    end
  end

  test 'search_activated? returns true if ENV is set' do
    ENV['SEARCH_INGESTABLE'] = 'true'
    assert @crag.send(:search_activated?)

    ENV['SEARCH_INGESTABLE'] = 'false'
    assert_not @crag.send(:search_activated?)
  end
end
