# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  include ActionView::Helpers::SanitizeHelper

  def new_message
    @user = params[:user]
    email_notifiable_list = @user.email_notifiable_list.presence || []
    return unless email_notifiable_list.include?('new_message')

    I18n.with_locale(@user.language) do
      to = @user.email
      subject = t('mailer.notification.new_message.title')
      if use_send_in_blue?
        send_with_send_in_blue(to, subject, 'notification_mailer/new_message')
      else
        mail(to: to, subject: subject)
      end
    end
  end

  def new_publications
    @user = params[:user]
    publications = params[:publications]
    @publications = []
    email_notifiable_list = @user.email_notifiable_list.presence || []
    return unless email_notifiable_list.include?('new_publication')

    renderer = Redcarpet::Render::HTML.new(
      no_images: true,
      hard_wrap: true
    )
    markdown = Redcarpet::Markdown.new(renderer)

    publications.each do |publication|
      body = markdown.render(strip_tags(publication.body))
      body.gsub!(/<h\d>/, '<p style="font-weight: 600;">')
      body.gsub!(%r{</h\d>}, '</p>')

      avatar = if publication.publishable_type == 'Gym' && publication.publishable.logo_attachment_object[:attached]
                 publication.publishable.logo_attachment_object[:variant_path].gsub(':variant', 'fit=crop,width=50,height=50')
               elsif publication.publishable_type == 'User' && publication.publishable.avatar_attachment_object[:attached]
                 publication.publishable.avatar_attachment_object[:variant_path].gsub(':variant', 'fit=crop,width=50,height=50')
               elsif publication.publishable_type == 'Crag' && publication.publishable.photo?.picture_attachment_object.try(:[], :attached)
                 publication.publishable.photo.picture_attachment_object[:variant_path].gsub(':variant', 'fit=crop,width=50,height=50')
               elsif publication.publishable_type == 'GuideBookPaper' && publication.publishable.cover_attachment_object[:attached]
                 publication.publishable.cover_attachment_object[:variant_path].gsub(':variant', 'fit=crop,width=50,height=50')
               end
      @publications << {
        body: body,
        avatar: avatar,
        publishable_name: publication.publishable.name,
        attachables_count: publication.attachables_count,
        publication_app_path: "#{@app_url}#{publication.publishable.app_path}/publications"
      }
    end

    I18n.with_locale(@user.language) do
      to = @user.email
      subject = t('mailer.notification.new_publications.title', count: @publications.size)
      if use_send_in_blue?
        send_with_send_in_blue(to, subject, 'notification_mailer/new_publications')
      else
        mail(to: to, subject: subject)
      end
    end
  end

  def request_for_follow_up
    @user = params[:user]
    email_notifiable_list = @user.email_notifiable_list.presence || []
    return unless email_notifiable_list.include?('request_for_follow_up')

    @follower = params[:follower]
    I18n.with_locale(@user.language) do
      to = @user.email
      subject = t('mailer.notification.request_for_follow_up.title')
      if use_send_in_blue?
        send_with_send_in_blue(to, subject, 'notification_mailer/request_for_follow_up')
      else
        mail(to: to, subject: subject)
      end
    end
  end

  def new_article
    @user = params[:user]
    email_notifiable_list = @user.email_notifiable_list.presence || []
    return unless email_notifiable_list.include?('new_article')

    @article = params[:article]
    I18n.with_locale(@user.language) do
      to = @user.email
      subject = t('mailer.notification.new_article.title')
      if use_send_in_blue?
        send_with_send_in_blue(to, subject, 'notification_mailer/new_article')
      else
        mail(to: to, subject: subject)
      end
    end
  end
end
