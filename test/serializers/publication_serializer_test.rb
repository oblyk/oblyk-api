# frozen_string_literal: true

require 'test_helper'

class PublicationSerializerTest < ActiveSupport::TestCase
  setup do
    @publication = publications(:publication_user)
    @serializer = PublicationSerializer.new(@publication)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @publication.id, attributes['id']
    assert_equal @publication.app_path, attributes['app_path']
    assert_equal @publication.body, attributes['body']
    assert_equal @publication.published_at.as_json, attributes['published_at']
    assert_equal @publication.draft, attributes['draft']
    assert_equal @publication.likes_count, attributes['likes_count']
    assert_equal @publication.comments_count, attributes['comments_count']
    assert_equal @publication.publishable_id, attributes['publishable_id']
    assert_equal @publication.publishable_type, attributes['publishable_type']
    if @publication.publishable_subject.nil?
      assert_nil attributes['publishable_subject']
    else
      assert_equal @publication.publishable_subject, attributes['publishable_subject']
    end
    if @publication.last_updated_at.nil?
      assert_nil attributes['last_updated_at']
    else
      assert_equal @publication.last_updated_at.as_json, attributes['last_updated_at']
    end
    if @publication.attachables_count.nil?
      assert_nil attributes['attachables_count']
    else
      assert_equal @publication.attachables_count, attributes['attachables_count']
    end
    if @publication.attachable_types_count.nil?
      assert_nil attributes['attachable_types_count']
    else
      assert_equal @publication.attachable_types_count, attributes['attachable_types_count']
    end
    assert_equal @publication.generated, attributes['generated']
    if @publication.pined_at.nil?
      assert_nil attributes['pined_at']
    else
      assert_equal @publication.pined_at.as_json, attributes['pined_at']
    end
    if @publication.viewed.nil?
      assert_nil attributes['viewed']
    else
      assert_equal @publication.viewed, attributes['viewed']
    end

    assert_equal @publication.created_at.as_json, attributes['history']['created_at']
    assert_equal @publication.updated_at.as_json, attributes['history']['updated_at']

    expected_add_this_week = @publication.published_at.present? && @publication.published_at > Time.current.beginning_of_week
    assert_equal expected_add_this_week, attributes['add_this_week']
  end

  test 'It contains relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['publication_attachments']
    assert_not_nil relationships['publishable']
    assert_not_nil relationships['author']
  end

  test 'It contains published_week_at for generated publications' do
    publication = publications(:publication_generated)
    serializer = PublicationSerializer.new(publication)
    serialization = JSON.parse(serializer.serializable_hash.to_json)
    attributes = serialization['data']['attributes']

    assert_equal publication.published_at.beginning_of_week.as_json, attributes['published_week_at']
  end
end
