# frozen_string_literal: true

class EmailNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform(notification_id)
    notification = Notification.find notification_id
    return if notification.read?

    case notification.notification_type
    when 'new_message'
      NotificationMailer.with(user: notification.user).new_message.deliver_now
    when 'new_publication'
      # Notifications of new publications are grouped together
      # and sent in the morning or afternoon using the SendPublicationsEmailsJob.
    when 'request_for_follow_up'
      follower = notification.notifiable
      NotificationMailer.with(user: notification.user, follower: follower).request_for_follow_up.deliver_now
    when 'new_article'
      article = notification.notifiable
      NotificationMailer.with(user: notification.user, article: article).new_article.deliver_now
    end
  end
end
