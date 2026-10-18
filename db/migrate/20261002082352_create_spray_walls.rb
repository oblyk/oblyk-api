class CreateSprayWalls < ActiveRecord::Migration[8.1]
  def change
    create_table :spray_walls do |t|
      t.string :name
      t.integer :number
      t.references :gym, foreign_key: true
      t.references :gym_sector, foreign_key: true
      t.references :gym_space, foreign_key: true
      t.boolean :draft, default: true
      t.integer :picture_height
      t.integer :picture_width
      t.datetime :opened_at
      t.datetime :archived_at
      t.integer :spray_wall_holds_count, default: 0
      t.integer :spray_wall_routes_count, default: 0
      t.timestamps
    end

    create_table :spray_wall_holds do |t|
      t.references :spray_wall, foreign_key: true
      t.json :points, null: false
      t.float :cx, null: false
      t.float :cy, null: false
      t.float :area, null: false
      t.float :min_x, null: false
      t.float :min_y, null: false
      t.float :max_x, null: false
      t.float :max_y, null: false
      t.float :confidence
      t.boolean :active, default: true
      t.string  :source, null: false, default: "manual"
      t.timestamps
    end

    create_table :spray_wall_pipelines do |t|
      t.references :spray_wall, foreign_key: true
      t.string :service
      t.string :status
      t.json :body
      t.datetime :start_at
      t.datetime :end_at
      t.timestamps
    end

    create_table :spray_wall_routes do |t|
      t.references :spray_wall, foreign_key: true
      t.references :user, foreign_key: true
      t.string :name
      # Difficulty
      t.integer :level_index
      t.integer :level_length
      t.string :level_color
      t.string :grade_text
      t.string :grade_value
      # Options
      t.boolean :foot_authorization # no foot, only small foot, free foot, hand
      t.boolean :circus
      # Count historisation
      t.integer :spray_wall_holds_count, default: 0
      t.integer :ascents_count, default: 0
      t.integer :comments_count, default: 0
      t.integer :likes_count, default: 0
      t.integer :videos_count, default: 0
      t.timestamps
    end

    create_table :spray_wall_route_holds do |t|
      t.references :spray_wall_route, foreign_key: true
      t.references :spray_wall_hold, foreign_key: true
      t.boolean :strat_hold, default: false
      t.boolean :end_hold, default: false
      t.string :hold_type # only hand, only foot, hand and foot, etc.
      t.integer :number
    end
  end
end
