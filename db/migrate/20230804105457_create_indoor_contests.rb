class CreateIndoorContests < ActiveRecord::Migration[6.0]
  def change
    # Global contest parameters
    create_table :contests do |t|
      t.references :gym, foreign_key: true
      t.string :name
      t.string :slug_name
      t.text :description
      t.date :start_date
      t.date :end_date
      t.date :subscription_start_date
      t.date :subscription_end_date
      t.datetime :subscription_closed_at
      t.integer :total_capacity
      t.string :categorization_type
      t.integer :contest_participants_count
      t.datetime :archived_at
      t.timestamps
    end

    # Wave for distribute climbers
    create_table :contest_waves do |t|
      t.string :name
      t.references :contest, foreign_key: true
      t.timestamps
    end

    # Contest categories, example : novice, expert, etc.
    create_table :contest_categories do |t|
      t.string :name
      t.string :slug_name
      t.text :description
      t.integer :order
      t.integer :capacity
      t.boolean :unisex
      t.string :registration_obligation
      t.integer :min_age
      t.integer :max_age
      t.boolean :auto_distribute
      t.boolean :waveable # Category is divide by wave
      t.integer :contest_participants_count
      t.references :contest, foreign_key: true
      t.timestamps
    end

    # The main stages of the contest, example : Boulder, Sport climbing, Speed climbing, etc.
    create_table :contest_stages do |t|
      t.string :climbing_type
      t.text :description
      t.integer :stage_order
      t.string :default_ranking_type
      t.date :stage_date # If the stage is not on the same day as the main contest
      t.references :contest, foreign_key: true
      t.timestamps
    end

    # Like : qualification, semi-final or final
    create_table :contest_stage_steps do |t|
      t.string :name
      t.string :slug_name
      t.integer :step_order
      t.string :ranking_type
      t.boolean :self_reporting # Participant judge themselves ?
      t.integer :default_participants_for_next_step
      t.references :contest_stage, foreign_key: true
      t.timestamps
    end

    # Contest participants
    create_table :contest_participants do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :genre
      t.string :email
      t.string :affiliation # club or climbing gym
      t.string :token, index: true
      t.references :contest_category, foreign_key: true
      t.references :user, foreign_key: true
      t.references :contest_wave, foreign_key: true
      t.timestamps
    end

    # Which participant is taking part in which stage
    create_table :contest_participant_steps do |t|
      t.integer :ranking
      t.references :contest_participant, foreign_key: true
      t.references :contest_stage_step, foreign_key: true
    end

    # Allows you to create groups of lanes in a stage to differentiate which category does which lane
    create_table :contest_route_groups do |t|
      t.boolean :waveable # Route groups is divided into waves, like Wave A, Wave B
      t.date :route_group_date # If the route group start_date is not on the same day as the main contest
      t.time :start_time # Start time for steps if is not waveable
      t.time :end_time # Same start_time but for end_time
      t.date :start_date # Start date for steps if is not waveable
      t.date :end_date # Same start_date but for end_date
      t.string :genre_type # female, male, or unisex
      t.integer :number_participants_for_next_step
      t.references :contest_stage_step, foreign_key: true
      t.timestamps
    end

    # Which category does which route (through the group)
    create_table :contest_route_group_categories do |t|
      t.references :contest_route_group, foreign_key: true
      t.references :contest_category, foreign_key: true
    end

    # Time of passage of waves on the different stages
    create_table :contest_time_blocks do |t|
      t.time :start_time
      t.time :end_time
      t.date :start_date
      t.date :end_date
      t.references :contest_wave, foreign_key: true
      t.references :contest_route_group, foreign_key: true
    end

    # Routes in contest
    create_table :contest_routes do |t|
      t.integer :number
      t.integer :number_of_holds
      t.datetime :disabled_at # Admin can remove a route (for any reason)
      t.references :contest_route_group, foreign_key: true
      t.references :gym_route, foreign_key: true # To link the contest route to a topo route
      t.timestamps
    end

    # Participants ascents
    create_table :contest_participant_ascents do |t|
      t.references :contest_participant, foreign_key: true
      t.references :contest_route, foreign_key: true
      t.datetime :registered_at
      # For boulder or sport climbing top or not top mode
      t.boolean :realised
      # For boulder with zone
      t.integer :zone_1_attempt
      t.integer :zone_2_attempt
      t.integer :top_attempt
      # For sport climbing
      t.integer :hold_number
      t.boolean :hold_number_plus
    end
  end
end
