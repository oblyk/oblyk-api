# frozen_string_literal: true

require 'test_helper'

class ArticleSerializerTest < ActiveSupport::TestCase
  setup do
    @article = articles(:article_1)
    @article.valid?
    @article.save
    @serializer = ArticleSerializer.new(@article)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @article.id, attributes['id']
    assert_equal @article.name, attributes['name']
    assert_equal @article.slug_name, attributes['slug_name']
    assert_equal @article.description, attributes['description']
    assert_equal @article.views, attributes['views']
    assert_nil attributes['comments_count']
    assert_nil attributes['likes_count']
    assert_equal @article.published_at.as_json, attributes['published_at']
    assert_equal @article.app_path, attributes['app_path']
    assert_equal @article.author_id, attributes['author_id']
    assert_equal @article.published?, attributes['published']
  end

  test 'It contains the body attribute only if specified' do
    assert_nil @serialization['data']['attributes']['body']

    serializer = ArticleSerializer.new(@article, { params: { with_body: true } })
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    assert_equal @article.body, serialization['data']['attributes']['body']
  end

  test 'It may include crags if specified' do
    serializer = ArticleSerializer.new(@article, { include: [:crags] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)

    assert_not_nil serialization['included']
  end

  test 'It may include guide_book_papers if specified' do
    serializer = ArticleSerializer.new(@article, { include: [:guide_book_papers] })
    serialization = JSON.parse(serializer.serializable_hash.to_json)

    assert_not_nil serialization['included']
  end

  test 'It may include author if specified' do
    @article.stub :author, users(:lulu) do
      serializer = ArticleSerializer.new(@article, { include: [:author] })
      serialization = JSON.parse(serializer.serializable_hash.to_json)
      assert_not_nil serialization['included']
      author_include = serialization['included'].find { |inc| inc['type'] == 'user' }
      assert_not_nil author_include
    end
  end

  test 'cover_attachment returns correct structure' do
    cover = ArticleSerializer.cover_attachment(@article)
    assert_kind_of Hash, cover
    assert cover.key?(:attached)
    assert cover.key?(:attachment_type)
    assert_equal 'Article_cover', cover[:attachment_type]
    assert cover.key?(:variant_path)
  end

  test 'avatar_attachment returns same as cover_attachment' do
    avatar = ArticleSerializer.avatar_attachment(@article)
    cover = ArticleSerializer.cover_attachment(@article)
    assert_equal cover, avatar
  end
end
