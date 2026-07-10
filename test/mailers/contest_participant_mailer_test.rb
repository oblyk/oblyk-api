# frozen_string_literal: true

require 'test_helper'

class ContestParticipantMailerTest < ActionMailer::TestCase
  setup do
    @gym = gyms(:my_gym)
    @contest = Contest.new(
      name: 'Contest Test',
      gym: @gym,
      start_date: Date.current,
      end_date: Date.current
    )
    @contest.save(validate: false)
    contest_category = ContestCategory.create!(
      contest: @contest,
      auto_distribute: false,
      name: 'Loisir'
    )
    contest_stage = ContestStage.create!(
      contest: @contest,
      climbing_type: Climb::BOULDERING
    )
    contest_stage_step = ContestStageStep.create!(
      name: 'Qualification',
      ranking_type: ContestService::Constant::DIVISION_AND_ZONE,
      contest_stage: contest_stage
    )
    ContestRouteGroup.create!(
      genre_type: 'unisex',
      contest_stage_step: contest_stage_step,
      contest_categories: [contest_category]
    )

    @contest_participant = ContestParticipant.create!(
      first_name: 'Lucien',
      last_name: 'Durand',
      genre: 'male',
      date_of_birth: Date.current - 42.years,
      email: 'lucien@durand.fr',
      token: 'fake-token-123',
      contest_category: contest_category,
      skip_subscription_mail: true
    )

    ENV['SEND_EMAIL_WITH'] = 'smtp'
    Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
  end

  test 'subscribe sends email with SMTP' do
    email = ContestParticipantMailer.with(contest_participant: @contest_participant).subscribe

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@contest_participant.email], email.to
    assert_equal "#{@contest.name}, votre inscription", email.subject
    assert_match /Bonjour #{@contest_participant.first_name}/, email.html_part.body.to_s
    assert_match /votre inscription/i, email.html_part.body.to_s
    assert_match /#{@contest.name}/, email.html_part.body.to_s
    assert_match /#{@contest_participant.token}/, email.html_part.body.to_s
    assert_match /#{Regexp.escape(@gym.name.titleize)}/, email.html_part.body.to_s

    assert_match /Bonjour #{@contest_participant.first_name}/, email.text_part.body.to_s
    assert_match /#{@contest_participant.token}/, email.text_part.body.to_s
    assert_match /#{Regexp.escape(@gym.name.titleize)}/, email.text_part.body.to_s
  end

  test 'subscribe sends email with SendInBlue' do
    ENV['SEND_EMAIL_WITH'] = 'send_in_blue'

    mock_api = Minitest::Mock.new
    mock_api.expect(:send_transac_email, nil) { |*_args, **_kwargs| true }

    Brevo::TransactionalEmailsApi.stub :new, mock_api do
      ContestParticipantMailer.with(contest_participant: @contest_participant).subscribe.deliver_now
    end

    assert_mock mock_api
  ensure
    ENV['SEND_EMAIL_WITH'] = 'smtp'
  end
end
