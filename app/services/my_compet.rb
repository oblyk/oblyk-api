# frozen_string_literal: true

class MyCompet
  def self.association_request(ffme_application)
    request = RestClient.post(
      "#{ENV['MY_COMPET_BASE_URL']}/demandeAssociation",
      {
        idPersonne: ffme_application.user.uuid,
        nom: ffme_application.user.full_name,
        numeroFFME: ffme_application.ffme_licence_number
      }.to_json,
      {
        content_type: :json,
        authorization: ENV['MY_COMPET_TOKEN']
      }
    )
    JSON.parse(request.body)
  rescue RestClient::ExceptionWithResponse => e
    RorVsWild.record_error(e)
    false
  end

  def self.create_contest(ffme_contest)
    MyCompet.update_or_create_contest ffme_contest, mode: :create
  end

  def self.update_contest(ffme_contest)
    MyCompet.update_or_create_contest ffme_contest, mode: :update
  end

  def self.link(ffme_contest)
    request = RestClient.post(
      "#{ENV['MY_COMPET_BASE_URL']}/urlCompetition",
      {
        idCompetition: ffme_contest.contest_id
      }.to_json,
      {
        content_type: :json,
        authorization: ENV['MY_COMPET_TOKEN']
      }
    )
    JSON.parse(request.body)
  rescue RestClient::ExceptionWithResponse => e
    RorVsWild.record_error(e)
    false
  end

  def self.send_results(ffme_contest)
    results = []
    contest_result = ContestService::Result.new ffme_contest.contest
    contest_result.delete_cache_key

    contest_result.results.each do |result|
      category = result[:category_name]
      genre = nil
      genre = 'HOMME' if result[:genre] == 'male'
      genre = 'FEMME' if result[:genre] == 'female'
      result[:participants].each do |participant|
        participant_id = if participant[:synchronise_with_ffme_contest] && participant[:user_uuid].present?
                           participant[:user_uuid]
                         else
                           participant[:participant_id]
                         end
        results << {
          idPersonne: participant_id.to_s,
          categorie: category,
          genre: genre,
          rang: participant[:global_rank].to_i
        }
      end
    end

    request = RestClient.post(
      "#{ENV['MY_COMPET_BASE_URL']}/envoiResultats",
      {
        idCompetition: ffme_contest.contest_id,
        resultats: results
      }.to_json,
      {
        content_type: :json,
        authorization: ENV['MY_COMPET_TOKEN']
      }
    )
    JSON.parse(request.body)
  rescue RestClient::ExceptionWithResponse => e
    RorVsWild.record_error(e)
    false
  end

  def self.update_or_create_contest(ffme_contest, mode: :create)
    contest_banner = ffme_contest.contest.banner_attachment_object
    banner_url = nil
    banner_url = contest_banner[:variant_path].gsub(':variant', 'onerror=redirect,fit=scale-down,width=1920,height=1920') if contest_banner[:attached]
    url_mode = mode == :create ? 'creationCompetition' : 'modificationCompetition'
    data = {
      idCompetition: ffme_contest.contest_id,
      type: ffme_contest.ffme_contest_type,
      complement: ffme_contest.name,
      debut: "#{ffme_contest.start_date}T00:00:00Z",
      fin: "#{ffme_contest.end_date}T00:00:00Z",
      structureOrganisatrice: ffme_contest.contest.gym.name,
      lieu: ffme_contest.contest.gym.address,
      ville: ffme_contest.contest.gym.insee_code,
      emailContact: ffme_contest.contact_email,
      telContact: ffme_contest.contact_phone,
      descriptionCompetition: ffme_contest.description,
      visuel: banner_url
    }
    request = RestClient.post(
      "#{ENV['MY_COMPET_BASE_URL']}/#{url_mode}",
      data.to_json,
      {
        content_type: :json,
        authorization: ENV['MY_COMPET_TOKEN']
      }
    )
    JSON.parse(request.body)
  rescue RestClient::ExceptionWithResponse => e
    RorVsWild.record_error(e)
    false
  end
end
