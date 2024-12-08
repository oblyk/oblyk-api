class CreateGymChains < ActiveRecord::Migration[6.0]
  def change
    create_table :gym_chains do |t|
      t.string :name
      t.string :slug_name
      t.text :description
      t.boolean :public_chain
      t.string :api_access_token
      t.timestamps
    end
    add_index :gym_chains, :slug_name, unique: true
    add_index :gym_chains, :api_access_token, unique: true

    create_table :gym_chain_gyms do |t|
      t.references :gym_chain, foreign_key: true
      t.references :gym, foreign_key: true
      t.timestamps
    end

    create_table :gym_chain_administrators do |t|
      t.references :gym_chain, foreign_key: true
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
