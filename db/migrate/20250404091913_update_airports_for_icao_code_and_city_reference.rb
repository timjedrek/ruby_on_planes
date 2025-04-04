class UpdateAirportsForIcaoCodeAndCityReference < ActiveRecord::Migration[8.0]
  def change
    # Add icao_code
    add_column :airports, :icao_code, :string
    add_index :airports, :icao_code, unique: true

    # Convert nearby_towns to array
    remove_column :airports, :nearby_towns, :string
    add_column :airports, :nearby_towns, :string, array: true, default: [], null: false

    # Add city reference and migrate data
    add_reference :airports, :city, null: true, foreign_key: true # Temporary null: true

    # Migrate existing city:string data to cities table
    reversible do |dir|
      dir.up do
        Airport.find_each do |airport|
          next unless airport.city.present?
          city = City.find_or_create_by!(name: airport.city, state_id: airport.state_id)
          airport.update!(city_id: city.id)
        end
      end
    end

    # Remove city:string and make city_id not null
    remove_column :airports, :city, :string
    change_column_null :airports, :city_id, false

    # Update indexes
    #remove_index :airports, [:state_id, :city] # Old index
    add_index :airports, [:state_id, :city_id] # New index
  end
end