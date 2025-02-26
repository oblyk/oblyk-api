class CreateIndoorSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :gyms, :gym_type, :string # private or club

    create_table :gym_billing_accounts do |t|
      t.string :uuid, index: true
      t.string :customer_stripe_id
      t.string :email
      t.timestamps
    end

    add_reference :gyms, :gym_billing_account, foreign_key: true

    create_table :indoor_subscription_products do |t|
      t.string :reference
      t.integer :order
      t.boolean :recommended
      t.monetize :price
      t.string :for_gym_type
      t.integer :month_by_occurrence
      t.string :product_stripe_id
      t.timestamps
    end

    create_table :indoor_subscriptions do |t|
      t.string :for_gym_type
      t.integer :month_by_occurrence
      t.date :start_date
      t.date :trial_end_date
      t.date :end_date
      t.datetime :cancelled_at
      t.string :payment_link
      t.string :payment_status
      t.string :subscription_stripe_id
      t.string :payment_link_stipe_id
      t.timestamps
    end

    create_table :indoor_subscription_gyms do |t|
      t.references :indoor_subscription, foreign_key: true
      t.references :gym, foreign_key: true
    end

    create_table :stripe_checkout_sessions do |t|
      t.string :checkout_session_id, index: true
      t.datetime :processed_at
      t.timestamps
    end
  end
end
