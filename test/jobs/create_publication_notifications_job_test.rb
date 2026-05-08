# frozen_string_literal: true

require 'test_helper'

class CreatePublicationNotificationsJobTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @crag = crags(:rocher_des_aures)
    @follow = Follow.create!(
      user: @user,
      followable: @crag,
      accepted_at: Time.current
    )
    @publication = Publication.create!(
      publishable: @crag,
      published_at: Time.current,
      body: 'New publication'
    )
  end

  test 'it creates notifications for followers who have not seen the publication' do
    assert_difference 'Notification.count', 1 do
      CreatePublicationNotificationsJob.perform_now(@publication.id)
    end

    notification = Notification.last
    assert_equal 'new_publication', notification.notification_type
    assert_equal 'Publication', notification.notifiable_type
    assert_equal @publication.id, notification.notifiable_id
    assert_equal @user.id, notification.user_id
  end

  test 'it does not create notification if publication has been seen' do
    PublicationView.create!(
      publication: @publication,
      user: @user
    )

    assert_no_difference 'Notification.count' do
      CreatePublicationNotificationsJob.perform_now(@publication.id)
    end
  end

  test 'it does not create notification if follow is not accepted' do
    # Pour un Crag, auto_accepted remplit accepted_at. On doit le mettre à nil après.
    @follow.update_column(:accepted_at, nil)

    assert_no_difference 'Notification.count' do
      CreatePublicationNotificationsJob.perform_now(@publication.id)
    end
  end

  test 'it does nothing if publication does not exist' do
    assert_nothing_raised do
      CreatePublicationNotificationsJob.perform_now(99_999)
    end
  end

  test 'it does nothing if publication is not published' do
    @publication.update!(published_at: nil)

    assert_no_difference 'Notification.count' do
      CreatePublicationNotificationsJob.perform_now(@publication.id)
    end
  end
end
