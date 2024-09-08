# frozen_string_literal: true

namespace :migrate_gym_grades do

  desc 'Migrate old gym_grade system to new level system'
  task :create_levels, %i[dry_run out] => :environment do |_t, args|
    out = args[:out] || $stdout
    dry_run = args[:dry_run] != 'false'

    out.puts '(dry_run)' if dry_run

    gyms = Gym.where.not(assigned_at: nil)
    gym_count = gyms.count
    gym_loop = 0
    out.puts "Nombre de salle a traiter : #{gym_count}"
    out.puts ''

    errors = []

    gyms.each do |gym|
      gym_loop += 1
      out.puts "#{gym_loop} / #{gym_count} #{gym.name} #{gym.id}"

      gym_grades = GymGrade.where(gym_id: gym.id)
      gym_grade_count = gym_grades.count
      grade_loop = 0

      out.puts "  System dans la salle : #{gym_grade_count}"
      out.puts ''

      bouldering_system = nil
      sport_climbing_system = nil
      pan_system = nil

      gym_grades.each do |gym_grade|
        grade_loop += 1
        out.puts "  #{gym_grade.name} #{gym_grade.gym.name}"

        gym_space_climbing_types = GymSpace.where(gym_grade_id: gym_grade.id)&.map(&:climbing_type)&.uniq || []
        out.puts "  space : #{gym_space_climbing_types}"

        gym_space_climbing_types.each do |climbing_type|
          level = GymLevel.new gym_id: gym.id, climbing_type: climbing_type
          level.grade_system = 'french' if gym_grade.difficulty_by_grade
          if gym_grade.tag_color && gym_grade.hold_color
            level.level_representation = 'hold_and_tag'
          elsif gym_grade.tag_color
            level.level_representation = 'tag'
          elsif gym_grade.hold_color
            level.level_representation = 'hold'
          else
            level.level_representation = 'hold_and_tag' if climbing_type == 'bouldering'
            level.level_representation = 'hold' if climbing_type == 'sport_climbing'
            level.level_representation = 'tag' if climbing_type == 'pan'
          end

          if gym_grade.difficulty_by_level
            levels = []
            gym_grade.gym_grade_lines.order(:order).each_with_index do |grade_line, grade_line_index|
              level_line = {
                order: grade_line_index,
                color: grade_line.colors.first
              }
              level_line[:default_grade] = grade_line.grade_text if grade_line.grade_text
              level_line[:default_point] = grade_line.points if grade_line.points&.positive?
              levels << level_line
            end
            level.levels = levels
          end

          if climbing_type == 'bouldering'
            if bouldering_system.blank?
              bouldering_system = level
            else
              errors << "La salle #{gym.name} (#{gym.id}) à déjà un système de difficulté pour #{climbing_type}"
            end
          end

          if climbing_type == 'sport_climbing'
            if sport_climbing_system.blank?
              sport_climbing_system = level
            else
              errors << "La salle #{gym.name} (#{gym.id}) à déjà un système de difficulté pour #{climbing_type}"
            end
          end

          if climbing_type == 'pan'
            if pan_system.blank?
              pan_system = level
            else
              errors << "La salle #{gym.name} (#{gym.id}) à déjà un système de difficulté pour #{climbing_type}"
            end
          end
        end

        out.puts ''
      end

      bouldering_system ||= GymLevel.new(gym_id: gym.id, climbing_type: Climb::BOULDERING, grade_system: nil, level_representation: GymLevel::TAG_AND_HOLD_REPRESENTATION)
      sport_climbing_system ||= GymLevel.new(gym_id: gym.id, climbing_type: Climb::SPORT_CLIMBING, grade_system: 'french', level_representation: GymLevel::HOLD_REPRESENTATION)
      pan_system ||= GymLevel.new(gym_id: gym.id, climbing_type: Climb::PAN, grade_system: 'french', level_representation: GymLevel::TAG_REPRESENTATION)

      if dry_run
        out.puts '  Test des validations des GymLevel'
        out.puts bouldering_system.valid? ? '  bouldering ok' : '  /!\ bouldering ko'
        out.puts sport_climbing_system.valid? ? '  sport climbing ok' : '  /!\ sport climbing ko'
        out.puts pan_system.valid? ? '  pan ok' : '  /!\ pan ko'
      else
        out.puts '  Sauvegarde des GymLevel'
        out.puts bouldering_system.save ? '  bouldering ok' : '  /!\ bouldering ko'
        out.puts sport_climbing_system.save ? '  sport_climbing ok' : '  /!\ sport_climbing ko'
        out.puts pan_system.save ? '  pan ok' : '  /!\ pan ko'
      end
      out.puts ''
    end

    if errors.count.positive?
      out.puts 'Liste des erreurs'
    else
      out.puts "Pas d'erreur"
    end

    # Écriture des erreurs
    errors.each do |error|
      out.puts error
    end
  end


  desc 'Migrate old gym_grade system to new level system'
  task :update_routes, %i[dry_run out] => :environment do |_t, args|
    out = args[:out] || $stdout
    dry_run = args[:dry_run] != 'false'

    out.puts '(dry_run)' if dry_run

    errors = []
    gyms = Gym.where.not(assigned_at: nil)
    gym_count = gyms.count
    out.puts "Nombre de salle a traiter : #{gym_count}"
    out.puts ''

    gyms.each_with_index do |gym, gym_index|
      out.puts "#{gym_index + 1} / #{gym_count} : #{gym.name} #{gym.id}"

      gym_routes = GymRoute.joins(gym_sector: :gym_space).where(gym_spaces: { gym_id: gym.id })
      gym_routes_count = gym_routes.count
      gym_levels = GymLevel.where(gym_id: gym.id)
      levels = {}
      gym_levels.each do |gym_level|
        levels[gym_level.climbing_type] = gym_level
      end

      gym_routes.each_with_index do |gym_route, index|
        out.puts "  Ligne : #{index + 1} / #{gym_routes_count} #{gym_route.name} #{gym_route.id}"

        color = if gym_route.tag_colors.present?
                  gym_route.tag_colors.first
                elsif gym_route.hold_colors.present?
                  gym_route.hold_colors.first
                end

        next unless color # Anciennes voies : 49 sur ~ 20 000 qui non pas de couleur

        gym_level = levels[gym_route.climbing_type]

        gym_level.levels&.each do |level|
          next unless level['color'] == color

          gym_route.level_index = level['order']
          gym_route.level_length = gym_level.levels.count
          gym_route.level_color = color
          out.puts "#{level['order']} #{gym_level.levels.count} #{color}"
          break
        end

        if dry_run
          if gym_route.valid?
            out.puts '  valide'
          else
            message = "#{gym_route.id} errors: #{gym_route.errors.full_messages.join(', ')}"
            errors << message
            out.puts "  #{message}"
          end
        elsif gym_route.save
          out.puts '  save'
        else
          message = "#{gym_route.id} errors: #{gym_route.errors.full_messages.join(', ')}"
          errors << message
          out.puts "  #{message}"
        end
      end
    end

    if errors.count.positive?
      out.puts 'Liste des erreurs'
    else
      out.puts "Pas d'erreur"
    end

    # Écriture des erreurs
    errors.each do |error|
      out.puts error
    end
  end
end
