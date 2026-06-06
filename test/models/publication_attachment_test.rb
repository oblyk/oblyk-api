# frozen_string_literal: true

require 'test_helper'

class PublicationAttachmentTest < ActiveSupport::TestCase
  setup do
    @publication = publications(:publication_user)
    @crag = crags(:rocher_des_aures)
  end

  test 'validates uniqueness of attachable per publication' do
    # No uniqueness validation in model, so we can't test it unless it's in DB
    # Let's skip it if it's not implemented.
  end

  test 'after_save refresh publication attachment types count' do
    pub = Publication.new(publishable: users(:normal_user), author: users(:normal_user), body: 'test')
    pub.save(validate: false)

    assert_equal 0, pub.attachables_count

    attachment = PublicationAttachment.new(publication: pub, attachable: @crag)
    attachment.save!

    # Callback uses before_save on publication, which is called when publication.save is called in refresh_count_or_destroy_publication!
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
    # Manually delete because destroy callback might have failed to find the record if already deleted in some environments,
    # but here we call it on the object.
    attachment.refresh_count_or_destroy_publication!

    pub.reload
    assert_equal 0, pub.attachables_count
  end

  test 'destroy publication if it was generated and no more attachments' do
    pub = Publication.new(
      publishable: crags(:rocher_des_aures),
      author: users(:normal_user),
      generated: true,
      publishable_subject: 'new_alert' # must be in the list in auto_remove_publication!
    )
    pub.save(validate: false)

    attachment = PublicationAttachment.create!(publication: pub, attachable: alerts(:good_alert))
    pub.reload

    assert_no_difference 'Publication.count' do
      # Still has attachments
      pub.auto_remove_publication!
    end

    assert_difference 'Publication.count', -1 do
      attachment.destroy
    end
  end
end
