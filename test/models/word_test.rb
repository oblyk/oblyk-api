# frozen_string_literal: true

require 'test_helper'

class WordTest < ActiveSupport::TestCase
  test 'is valid with name and definition' do
    word = Word.new(name: 'Bac', definition: 'Une grosse prise')
    assert word.valid?
  end

  test 'is invalid without name' do
    word = Word.new(definition: 'Une grosse prise')
    assert_not word.valid?
    assert_not_empty word.errors[:name]
  end

  test 'is invalid without definition' do
    word = Word.new(name: 'Bac')
    assert_not word.valid?
    assert_not_empty word.errors[:definition]
  end

  test 'generates slug_name before validation' do
    word = Word.new(name: 'Grosse Prise', definition: 'Définition')
    word.validate
    assert_equal 'grosse-prise', word.slug_name
  end

  test 'app_path returns the correct path' do
    word = words(:with_fingers)
    word.validate
    assert_equal "/words/#{word.id}/#{word.slug_name}", word.app_path
  end

  test 'summary_to_json returns correct keys' do
    word = words(:with_fingers)
    word.validate
    summary = word.summary_to_json
    assert_equal word.id, summary[:id]
    assert_equal word.name, summary[:name]
    assert_equal word.app_path, summary[:app_path]
    assert_equal word.slug_name, summary[:slug_name]
    assert_equal word.definition, summary[:definition]
  end

  test 'detail_to_json returns correct keys' do
    word = words(:with_fingers)
    detail = word.detail_to_json
    assert_equal word.id, detail[:id]
    assert detail.key?(:versions_count)
    assert detail.key?(:creator)
    assert detail.key?(:history)
    assert_equal word.created_at, detail[:history][:created_at]
  end

  test 'strips tags from definition before validation' do
    word = Word.new(name: 'Tag test', definition: '<p>Définition avec <b>tags</b></p>')
    word.validate
    assert_equal 'Définition avec tags', word.definition
  end
end
