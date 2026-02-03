# frozen_string_literal: true

class SendPublicationsEmailsJob < ApplicationJob
  queue_as :low

  def perform
    yesterday = DateTime.yesterday
    notification_by_users = Notification.joins(:user)
                                        .includes(:notifiable)
                                        .where(notification_type: 'new_publication', notifiable_type: 'Publication')
                                        .where("JSON_SEARCH(users.email_notifiable_list, 'one', 'new_publication')")
                                        .where(read_at: nil)
                                        .where(email_notification_sent_at: nil)
                                        .where(posted_at: [yesterday.beginning_of_day..yesterday.end_of_day])
                                        .group_by(&:user_id)

    notification_by_users.each do |_user_id, notifications|
      publications = notifications.map(&:notifiable)
      user = notifications.first.user
      NotificationMailer.with(user: user, publications: publications).new_publications.deliver_now

      notifications = Notification.where(user: user, notification_type: 'new_publication', notifiable_type: 'Publication', notifiable_id: publications.map(&:id))
      notifications.update_all(email_notification_sent_at: DateTime.now)
    end

    tomorrow_at_nine_am = DateTime.tomorrow.beginning_of_day + 9.hours
    self.class.set(wait_until: tomorrow_at_nine_am).perform_later
  end
end
