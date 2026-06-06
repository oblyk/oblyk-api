# frozen_string_literal: true

require 'test_helper'

class ArchivableTest < ActiveSupport::TestCase
  setup do
    @contest = contests(:contest_1)
  end

  test 'archived scope returns only archived objects' do
    @contest.archive!
    assert_includes Contest.archived, @contest
    
    @contest.unarchive!
    assert_not_includes Contest.archived, @contest
  end

  test 'unarchived scope returns only unarchived objects' do
    @contest.unarchive!
    assert_includes Contest.unarchived, @contest
    
    @contest.archive!
    assert_not_includes Contest.unarchived, @contest
  end

  test 'archive! sets archived_at' do
    assert_nil @contest.archived_at
    @contest.archive!
    assert_not_nil @contest.archived_at
  end

  test 'unarchive! clears archived_at' do
    @contest.archive!
    assert_not_nil @contest.archived_at
    @contest.unarchive!
    assert_nil @contest.archived_at
  end

  test 'archived? returns true if archived_at is present and in the past' do
    @contest.archived_at = 1.day.ago
    assert @contest.archived?
    
    @contest.archived_at = nil
    assert_not @contest.archived?
    
    @contest.archived_at = 1.day.from_now
    assert_not @contest.archived?
  end

  test 'unarchived? returns true if not archived' do
    @contest.archived_at = nil
    assert @contest.unarchived?
    
    @contest.archived_at = 1.day.ago
    assert_not @contest.unarchived?
  end
end
