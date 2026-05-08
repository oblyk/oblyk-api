# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:normal_user)
    # On s'assure que SEND_EMAIL_WITH n'est pas 'send_in_blue' pour tester ActionMailer standard
    ENV['SEND_EMAIL_WITH'] = 'smpt'
    Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
  end

  test 'welcome' do
    email = UserMailer.with(user: @user).welcome

    # Test de l'envoi
    assert_emails 1 do
      email.deliver_now
    end

    # Test du contenu
    assert_equal [@user.email], email.to
    assert_equal "Bienvenue #{@user.first_name}", email.subject
    assert_match /Bienvenue #{@user.first_name} !/, email.html_part.body.to_s
    assert_match /Bienvenue #{@user.first_name} !/, email.text_part.body.to_s
  end

  test 'reset_password' do
    token = 'fake-token'
    email = UserMailer.with(user: @user, token: token).reset_password

    # Test de l'envoi
    assert_emails 1 do
      email.deliver_now
    end

    # Test du contenu
    assert_equal [@user.email], email.to
    assert_equal 'Mot de passe oublié', email.subject
    assert_match /#{token}/, email.html_part.body.to_s
    assert_match /#{token}/, email.text_part.body.to_s
  end

  test 'welcome in english' do
    @user.update_column(:language, 'en')
    email = UserMailer.with(user: @user).welcome

    assert_equal "Welcome #{@user.first_name}", email.subject
  end

  test 'send welcome with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'

    # Mock de l'API Send In Blue
    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [SibApiV3Sdk::SendSmtpEmail]

    SibApiV3Sdk::TransactionalEmailsApi.stub :new, mock_api do
      UserMailer.with(user: @user).welcome.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smpt'
  end

  test 'send reset_password with send_in_blue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'

    # Mock de l'API Send In Blue
    mock_api = Minitest::Mock.new
    mock_api.expect :send_transac_email, nil, [SibApiV3Sdk::SendSmtpEmail]

    SibApiV3Sdk::TransactionalEmailsApi.stub :new, mock_api do
      UserMailer.with(user: @user, token: 'fake-token').reset_password.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smpt'
  end
end
