# frozen_string_literal: true

require 'test_helper'

class StripTagableTest < ActiveSupport::TestCase
  test 'strip_tag_column strips tags from description' do
    contest = Contest.new(name: 'Test', description: '<p>Hello</p> <b>World</b>')
    contest.send(:strip_tag_column)
    assert_equal 'Hello World', contest.description
  end

  test 'strip_tag_column strips tags from definition' do
    word = Word.new(name: 'Test', definition: '<i>Definition</i>')
    word.valid?
    assert_equal 'Definition', word.definition
  end

  test 'strip_tag_column strips tags from body' do
    message = ConversationMessage.new(body: '<div>Body</div>')
    message.valid?
    assert_equal 'Body', message.body
  end
end
