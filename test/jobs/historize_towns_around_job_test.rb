# frozen_string_literal: true

require 'test_helper'

class HistorizeTownsAroundJobTest < ActiveJob::TestCase
  setup do
    @valence = towns(:valence) # Lat: 44.9333, Long: 4.8917, Pop: 62000
    @beaufort = towns(:beaufort) # Lat: 44.7167, Long: 5.1167, Pop: 500
    # Distance Valence - Beaufort est d'environ 29km.
    # Pour une ville > 50000 hab (Valence), le rayon est de 30km.
    # Pour une ville < 10000 hab (Beaufort), le rayon est de 10km.
  end

  test 'it historizes towns within the correct distance based on population' do
    # On force updated_at dans le passé pour les fixtures
    @valence.update_column(:updated_at, 1.day.ago)
    @beaufort.update_column(:updated_at, 1.day.ago)

    # On se place à Beaufort
    latitude = @beaufort.latitude
    longitude = @beaufort.longitude
    request_date = Time.current

    # Valence est à ~29km. Comme sa population est > 50000, elle devrait être incluse si on est dans un rayon de 30km d'elle.
    # Mais le job calcule la distance depuis le point donné vers les villes.
    # Si le point est Beaufort :
    # Valence est à 29km de Beaufort. Population Valence > 50000 -> rayon 30km -> OK.
    # Beaufort est à 0km de Beaufort. Population Beaufort < 10000 -> rayon 10km -> OK.

    assert_enqueued_with(job: HistorizeTownJob, args: [@valence.id]) do
      assert_enqueued_with(job: HistorizeTownJob, args: [@beaufort.id]) do
        HistorizeTownsAroundJob.perform_now(latitude, longitude, request_date)
      end
    end
  end

  test 'it does not historize towns that are too far' do
    # On se place loin de tout (ex: 0, 0)
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
    
    # Si on met une date de requête dans le passé, Valence et Beaufort ne devraient pas être prises
    # car leurs fixtures ont probablement un updated_at récent ou elles sont considérées comme "anciennes" par défaut.
    # Pour être sûr, on met à jour updated_at
    @valence.update_column(:updated_at, Time.current)
    @beaufort.update_column(:updated_at, Time.current)
    
    request_date = 1.hour.ago

    assert_no_enqueued_jobs(only: HistorizeTownJob) do
      HistorizeTownsAroundJob.perform_now(latitude, longitude, request_date)
    end
  end
  
  test 'it respects different population tiers' do
    # On met à jour les fixtures pour qu'elles ne soient pas sélectionnées par la date
    Town.update_all(updated_at: Time.current)
    request_date = 1.hour.ago

    # On crée une ville de taille moyenne, avec un updated_at ancien pour qu'elle soit éligible
    middle_town = Town.create!(
      name: 'Middle Town',
      latitude: @beaufort.latitude + 0.12, # Environ 13-14 km de Beaufort
      longitude: @beaufort.longitude,
      population: 15000,
      updated_at: 1.day.ago,
      slug_name: 'middle-town',
      town_code: '12345',
      zipcode: '12345',
      department: departments(:drome)
    )
    
    # Distance de Beaufort (~13.3 km)
    # Tier 10001-25000 -> rayon 15km. Devrait être incluse depuis Beaufort.
    
    assert_enqueued_with(job: HistorizeTownJob, args: [middle_town.id]) do
      HistorizeTownsAroundJob.perform_now(@beaufort.latitude, @beaufort.longitude, request_date)
    end
    
    # Si on s'éloigne un peu plus (ex: 22km)
    middle_town.update_columns(latitude: @beaufort.latitude + 0.20) 
    # 0.20 degree lat ~= 22.2 km
    
    # On se place à nouveau à Beaufort. 
    # Comme les fixtures ont un updated_at récent et middle_town est trop loin, 0 job attendu.
    assert_no_enqueued_jobs(only: HistorizeTownJob) do
       HistorizeTownsAroundJob.perform_now(@beaufort.latitude, @beaufort.longitude, request_date)
    end
  end
end
