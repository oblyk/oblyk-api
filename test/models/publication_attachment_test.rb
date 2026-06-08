# frozen_string_literal: true

require 'test_helper'

class PublicationAttachmentTest < ActiveSupport::TestCase
  setup do
    @publication = publications(:publication_user)
    @crag = crags(:rocher_des_aures)
  end

  test 'after_save refresh publication attachment types count' do
    pub = Publication.new(publishable: users(:normal_user), author: users(:normal_user), body: 'test')
    pub.save(validate: false)

    assert_equal 0, pub.attachables_count

    attachment = PublicationAttachment.new(publication: pub, attachable: @crag)
    attachment.save!

    attachment.refresh_count_or_destroy_publication!

    pub.reload
    assert_equal 0, pub.attachables_count
    assert_equal({}, pub.attachable_types_count)
  end

  test 'after_destroy refresh publication attachment types count' do
    pub = Publication.new(publishable: users(:normal_user), author: users(:normal_user), body: 'test')
    pub.save(validate: false)

    attachment = PublicationAttachment.new(publication: pub, attachable: @crag)
    attachment.save!
    attachment.refresh_count_or_destroy_publication!

    pub.reload
    assert_equal 0, pub.attachables_count

    attachment.destroy
    attachment.refresh_count_or_destroy_publication!

    pub.reload
    assert_equal 0, pub.attachables_count
  end

  test 'destroy publication if it was generated and no more attachments' do
    pub = Publication.new(
      publishable: crags(:rocher_des_aures),
      author: users(:normal_user),
      generated: true,
      publishable_subject: 'new_alert'
    )
    pub.save(validate: false)

    attachment = PublicationAttachment.create!(publication: pub, attachable: alerts(:good_alert))
    pub.reload

    assert_no_difference 'Publication.count' do
      pub.auto_remove_publication!
    end

    assert_difference 'Publication.count', -1 do
      attachment.destroy
    end
  end
end
