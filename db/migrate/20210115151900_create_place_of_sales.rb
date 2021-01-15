class CreatePlaceOfSales < ActiveRecord::Migration[6.0]
  def change
    create_table :place_of_sales do |t|
      t.string :name
      t.string :url
      t.text :description

      t.decimal :latitude, precision: 10, scale: 6, nil: true
      t.decimal :longitude, precision: 10, scale: 6, nil: true
      t.string :code_country
      t.string :country
      t.string :postal_code
      t.string :city
      t.string :region
      t.string :address

      t.references :guide_book_paper
      t.references :user

      t.timestamps
    end
  end
end
