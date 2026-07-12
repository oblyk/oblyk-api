# frozen_string_literal: true

require 'test_helper'

class ContestParticipantTest < ActiveSupport::TestCase
  setup do
    @participant_1 = contest_participants(:participant_1)
    @participant_2 = contest_participants(:participant_2)
    @category_senior = contest_categories(:category_senior)
    @category_u18 = contest_categories(:category_u18)
    @contest = contests(:contest_1)
  end

  test 'participant is valid' do
    assert @participant_1.valid?
  end

  test 'participant is invalid without mandatory fields' do
    @participant_1.first_name = nil
    assert_not @participant_1.valid?
    assert_includes @participant_1.errors.attribute_names, :first_name

    @participant_1.first_name = 'Jean'
    @participant_1.last_name = nil
    assert_not @participant_1.valid?
    assert_includes @participant_1.errors.attribute_names, :last_name

    @participant_1.last_name = 'Dujardin'
    @participant_1.date_of_birth = nil
    assert_not @participant_1.valid?
    assert_includes @participant_1.errors.attribute_names, :date_of_birth
  end

  test 'participant is invalid with wrong genre' do
    @participant_1.genre = 'other'
    assert_not @participant_1.valid?
    assert_includes @participant_1.errors.attribute_names, :genre
  end

  test 'age returns expected value' do
    @participant_1.date_of_birth = 20.years.ago.to_date
    assert_equal 20, @participant_1.age
  end

  test 'slug_name returns parameterized name' do
    @participant_1.first_name = 'Jean-Luc'
    @participant_1.last_name = 'D-Humieres'
    assert_equal 'jean-luc-d-humieres', @participant_1.slug_name
  end

  test 'participant is invalid if too young' do
    @participant_1.date_of_birth = 2.years.ago.to_date
    assert_not @participant_1.valid?
    assert_includes @participant_1.errors.full_messages.to_s, '3 ans ou plus'
  end

  test 'participant is invalid if category obligations not met' do
    participant = ContestParticipant.new(
      first_name: 'Petit',
      last_name: 'Jeune',
      date_of_birth: 15.years.ago.to_date,
      genre: 'male',
      contest_category: @category_senior
    )
    assert_not participant.valid?
    assert_includes participant.errors.full_messages.to_s, "pas s'inscrire en Senior"
  end

  test 'participant is invalid if contest is complete' do
    @contest.update_column(:total_capacity, 2)
    participant = ContestParticipant.new(
      first_name: 'Extra',
      last_name: 'Participant',
      date_of_birth: 25.years.ago.to_date,
      genre: 'female',
      contest_category: @category_senior
    )
    assert_not participant.valid?
    assert_includes participant.errors.full_messages.to_s, 'contest_is_complete'
  end

  test 'token is generated on create' do
    participant = ContestParticipant.create(
      first_name: 'Nouveau',
      last_name: 'Participant',
      date_of_birth: 25.years.ago.to_date,
      genre: 'female',
      contest_category: @category_senior,
      skip_subscription_mail: true
    )
    assert_not_nil participant.token
    assert participant.token.start_with?('nouveau.')
  end

  test 'unique_participant validation' do
    participant = ContestParticipant.new(
      first_name: @participant_1.first_name,
      last_name: @participant_1.last_name,
      date_of_birth: @participant_1.date_of_birth,
      contest_category: @category_senior
    )
    assert_not participant.valid?
    assert_includes participant.errors.full_messages.to_s, 'participant_is_already_registered'
  end

  test 'summary_to_json returns expected keys' do
    json = @participant_1.summary_to_json
    assert_equal @participant_1.id, json[:id]
    assert_equal @participant_1.first_name, json[:first_name]
    assert_includes json.keys, :token
    assert_includes json.keys, :contest_category
  end
end
