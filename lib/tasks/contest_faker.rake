# frozen_string_literal: true

namespace :contest_faker do
  desc 'Subscribe participant'
  task :subscribe, %i[contest_id nb_participants dry_run out] => :environment do |_t, args|
    out = args[:out] || $stdout
    dry_run = args[:dry_run] != 'false'

    genres = %w[male female]
    contest = Contest.find args[:contest_id]
    nb_participants = args[:nb_participants].to_i
    gym_names = Gym.all.pluck(:name)
    gyms_count = gym_names.size
    categories = contest.contest_categories
    waves = contest.contest_waves
    participant_created = 0
    creation_attempt = 0

    out.puts "Création de #{nb_participants} participants"
    out.puts ''
    while participant_created < nb_participants
      creation_attempt += 1
      genre = genres[rand(0..1)]
      first_name = genre == 'male' ? Faker::Name.male_first_name : Faker::Name.female_first_name
      last_name = Faker::Name.last_name
      affiliation = nil
      wave = nil
      affiliation = gym_names[rand(0..gyms_count - 1)] if chance(30) # ~30% fo chance to have affiliation
      category = categories[rand(0..categories.size - 1)]
      wave = waves[rand(0..waves.size - 1)] if category.waveable
      participant = ContestParticipant.new(
        first_name: first_name,
        last_name: last_name,
        date_of_birth: Faker::Date.between(from: 70.years.ago, to: 4.years.ago),
        genre: genre,
        email: Faker::Internet.email(name: "#{first_name} #{last_name}", separators: %w[- .]),
        affiliation: affiliation,
        contest_category: category,
        contest_wave: wave
      )
      participant_message = "#{first_name} #{last_name} cat : #{category.name}, age : #{participant.age}"
      if dry_run
        if participant.valid?
          participant_created += 1
          out.puts "=> #{participant_message} : valid"
        else
          out.puts "x  #{participant_message} : erreur : #{participant.errors.full_messages}"
        end
      elsif participant.save
        participant_created += 1
        out.puts "=> #{participant_message} : créé"
      else
        out.puts "x  #{participant_message} : erreur : #{participant.errors.full_messages}"
      end

      break if creation_attempt > 1000
    end

    out.puts ''
    out.puts 'Fin'
    out.puts "#{creation_attempt} tentatives pour #{nb_participants} création de participant"
  end

  task :make_ascents, %i[step_id dry_run out] => :environment do |_t, args|
    out = args[:out] || $stdout
    dry_run = args[:dry_run] != 'false'
    step = ContestStageStep.find args[:step_id]
    step.contest_participant_steps.each do |contest_participant_step|
      participant = contest_participant_step.contest_participant
      stronger = rand(10..90)
      out.puts "Réalisation de #{participant.first_name} #{participant.last_name}, talent : #{stronger}%"
      step.contest_route_groups
          .joins(:contest_categories)
          .where(contest_categories: { id: participant.contest_category_id })
          .each do |contest_route_group|
        contest_route_group.contest_routes.each do |contest_route|
          realised = chance(stronger)
          ascent = ContestParticipantAscent.find_or_initialize_by contest_participant: participant, contest_route: contest_route
          ascent.realised = realised
          out.puts "  -> #{contest_route.number} : #{realised ? 'fait!' : 'raté ...'}"
          ascent.save unless dry_run
        end
      end
    end
  end

  def chance(percent)
    rand(1..100) <= percent
  end
end
