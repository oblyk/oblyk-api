# frozen_string_literal: true

require 'test_helper'

class PublicationAttachmentSerializerTest < ActiveSupport::TestCase
  setup do
    @publication_attachment = publication_attachments(:attachment_photo)
    @serializer = PublicationAttachmentSerializer.new(@publication_attachment)
    @serialization = JSON.parse(@serializer.serializable_hash.to_json)
  end

  test 'It contains the basic attributes' do
    attributes = @serialization['data']['attributes']
    assert_equal @publication_attachment.id, attributes['id']
    assert_equal @publication_attachment.attachable_type, attributes['attachable_type']
    assert_equal @publication_attachment.attachable_id, attributes['attachable_id']
  end

  test 'It contains relationships' do
    relationships = @serialization['data']['relationships']
    assert_not_nil relationships['publication']
    assert_not_nil relationships['attachable']
  end
end
