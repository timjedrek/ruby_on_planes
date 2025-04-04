class CreateAirportsCities < ActiveRecord::Migration[8.0]
  def change
    create_table :airports_cities do |t|
      t.references :airport, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.timestamps
    end
    add_index :airports_cities, [:airport_id, :city_id], unique: true
  end
end