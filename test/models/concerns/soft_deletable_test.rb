# frozen_string_literal: true

require 'test_helper'

class SoftDeletableTest < ActiveSupport::TestCase
  setup do
    @crag = crags(:orpierre)
  end

  test 'default scope excludes deleted objects' do
    assert_includes Crag.all, @crag
    @crag.delete
    assert_not_includes Crag.all, @crag
  end

  test 'deleted scope returns only deleted objects' do
    @crag.delete
    assert_includes Crag.unscoped.deleted, @crag
  end

  test 'deleted? returns true if deleted_at is present and in the past' do
    @crag.deleted_at = 1.day.ago
    assert @crag.deleted?

    @crag.deleted_at = nil
    assert_not @crag.deleted?

    @crag.deleted_at = 1.day.from_now
    assert_not @crag.deleted?
  end

  test 'delete sets deleted_at' do
    assert_nil @crag.deleted_at
    @crag.delete
    assert_not_nil @crag.deleted_at
  end

  test 'destroy sets deleted_at' do
    assert_nil @crag.deleted_at
    @crag.destroy
    assert_not_nil @crag.deleted_at
  end
end
