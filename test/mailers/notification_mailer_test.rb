# frozen_string_literal: true

require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:normal_user)
    @user.update_column(:email_notifiable_list, %w[new_message new_publication request_for_follow_up new_article])
    ENV['SEND_EMAIL_WITH'] = 'smtp'
    Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
  end

  test 'new_message' do
    email = NotificationMailer.with(user: @user).new_message

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_match /nouveau message/, email.subject.downcase
  end

  test 'new_message should not send if user has not new_message in email_notifiable_list' do
    @user.update_column(:email_notifiable_list, [])
    email = NotificationMailer.with(user: @user).new_message

    assert_emails 0 do
      email.deliver_now
    end
  end

  test 'new_message with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'

    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [SibApiV3Sdk::SendSmtpEmail]

    SibApiV3Sdk::TransactionalEmailsApi.stub :new, mock_api do
      NotificationMailer.with(user: @user).new_message.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'new_publications' do
    publication = Publication.new(
      publishable: @user,
      body: 'Nouvelle publication',
      attachables_count: 0
    )
    email = NotificationMailer.with(user: @user, publications: [publication]).new_publications

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_match /nouvelle publication/, email.subject.downcase
  end

  test 'new_publications with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    publication = Publication.new(
      publishable: @user,
      body: 'Nouvelle publication',
      attachables_count: 0
    )

    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [SibApiV3Sdk::SendSmtpEmail]

    SibApiV3Sdk::TransactionalEmailsApi.stub :new, mock_api do
      NotificationMailer.with(user: @user, publications: [publication]).new_publications.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'request_for_follow_up' do
    follower = users(:super_admin_user)
    email = NotificationMailer.with(user: @user, follower: follower).request_for_follow_up

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_match /souhaite vous suivre/, email.subject.downcase
  end

  test 'request_for_follow_up with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    follower = users(:super_admin_user)

    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [SibApiV3Sdk::SendSmtpEmail]

    SibApiV3Sdk::TransactionalEmailsApi.stub :new, mock_api do
      NotificationMailer.with(user: @user, follower: follower).request_for_follow_up.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end

  test 'new_article' do
    author = Author.new(name: 'Test Author', user: @user)
    article = Article.new(name: 'Test Article', body: 'Body', author: author)
    email = NotificationMailer.with(user: @user, article: article).new_article

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@user.email], email.to
    assert_match /nouvel article/, email.subject.downcase
  end

  test 'new_article with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'
    author = Author.new(name: 'Test Author', user: @user)
    article = Article.new(name: 'Test Article', body: 'Body', author: author)

    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [SibApiV3Sdk::SendSmtpEmail]

    SibApiV3Sdk::TransactionalEmailsApi.stub :new, mock_api do
      NotificationMailer.with(user: @user, article: article).new_article.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end
end
