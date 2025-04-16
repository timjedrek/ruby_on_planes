class CreateNearbyCities < ActiveRecord::Migration[8.0]
  def change
    # First remove the array column from cities
    remove_column :cities, :nearby_cities, :string, array: true, default: [], null: false
    
    # Then create the nearby_cities join table
    create_table :nearby_cities do |t|
      t.references :city, null: false, foreign_key: true
      t.references :nearby_city, null: false, foreign_key: { to_table: :cities }
      t.timestamps
      
      t.index [:city_id, :nearby_city_id], unique: true
    end
  end
end
