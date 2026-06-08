# frozen_string_literal: true

require 'test_helper'

class HistorizeTownsAroundJobTest < ActiveJob::TestCase
  setup do
    @valence = towns(:valence)
    @beaufort = towns(:beaufort)
  end

  test 'it historizes towns within the correct distance based on population' do
    @valence.update_column(:updated_at, 1.day.ago)
    @beaufort.update_column(:updated_at, 1.day.ago)

    latitude = @beaufort.latitude
    longitude = @beaufort.longitude
    request_date = Time.current

    assert_enqueued_with(job: HistorizeTownJob, args: [@valence.id]) do
      assert_enqueued_with(job: HistorizeTownJob, args: [@beaufort.id]) do
        HistorizeTownsAroundJob.perform_now(latitude, longitude, request_date)
      end
    end
  end

  test 'it does not historize towns that are too far' do
    latitude = 0
    longitude = 0
    request_date = Time.current

    assert_no_enqueued_jobs(only: HistorizeTownJob) do
      HistorizeTownsAroundJob.perform_now(latitude, longitude, request_date)
    end
  end

  test 'it only historizes towns updated before the request date' do
    latitude = @beaufort.latitude
    longitude = @beaufort.longitude

    @valence.update_column(:updated_at, Time.current)
    @beaufort.update_column(:updated_at, Time.current)

    request_date = 1.hour.ago

    assert_no_enqueued_jobs(only: HistorizeTownJob) do
      HistorizeTownsAroundJob.perform_now(latitude, longitude, request_date)
    end
  end

  test 'it respects different population tiers' do
    Town.update_all(updated_at: Time.current)
    request_date = 1.hour.ago

    middle_town = Town.create!(
      name: 'Middle Town',
      latitude: @beaufort.latitude + 0.12,
      longitude: @beaufort.longitude,
      population: 15_000,
      updated_at: 1.day.ago,
      slug_name: 'middle-town',
      town_code: '12345',
      zipcode: '12345',
      department: departments(:drome)
    )

    assert_enqueued_with(job: HistorizeTownJob, args: [middle_town.id]) do
      HistorizeTownsAroundJob.perform_now(@beaufort.latitude, @beaufort.longitude, request_date)
    end

    middle_town.update_columns(latitude: @beaufort.latitude + 0.20)

    assert_no_enqueued_jobs(only: HistorizeTownJob) do
      HistorizeTownsAroundJob.perform_now(@beaufort.latitude, @beaufort.longitude, request_date)
    end
  end
end
