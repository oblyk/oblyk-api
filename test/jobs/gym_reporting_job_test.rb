# frozen_string_literal: true

require 'test_helper'

class GymReportingJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    GymAdministrator.update_all(email_report: false)
    Gym.update_all(assigned_at: nil)

    @gym = gyms(:my_gym)
    @user = users(:super_admin_user)
    @admin = gym_administrators(:gym_administrator_one)

    @admin.update_column(:email_report, true)
    @gym.update_column(:assigned_at, Time.current)
  end

  test 'it sends reporting email to administrators' do
    assert_enqueued_emails 1 do
      GymReportingJob.perform_now
    end

    next_month = Date.current.next_month.beginning_of_month.beginning_of_day + 9.hours
    assert_enqueued_with(job: GymReportingJob, at: next_month)
  end

  test 'it only sends emails to administrators with email_report enabled' do
    @admin.update_column(:email_report, false)

    assert_enqueued_emails 0 do
      GymReportingJob.perform_now
    end
  end

  test 'it calculates statistics correctly' do
    last_month_start = Date.current.prev_month.beginning_of_month
    last_month_mid = last_month_start + 15.days

    Follow.create!(
      followable: @gym,
      user: users(:normal_user),
      created_at: last_month_mid
    )

    gym_space = GymSpace.create!(
      gym: @gym,
      name: 'Espace 1',
      climbing_type: 'bouldering'
    )
    gym_sector = GymSector.create!(
      gym_space: gym_space,
      name: 'Secteur 1',
      climbing_type: 'bouldering',
      height: 4
    )
    GymRoute.create!(
      gym_sector: gym_sector,
      climbing_type: 'bouldering',
      opened_at: last_month_mid,
      name: 'Voie test',
      sections: [{ grade: '6a', height: 4 }]
    )

    assert_enqueued_emails 1 do
      GymReportingJob.perform_now
    end
  end
end
