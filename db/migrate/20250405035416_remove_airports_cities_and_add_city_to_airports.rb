class RemoveAirportsCitiesAndAddCityToAirports < ActiveRecord::Migration[7.1]
  def change
    # Safely drop the airports_cities table if it exists
    drop_table :airports_cities, if_exists: true

    # Add city_id to airports as nullable first, only if the column doesn't exist
    unless column_exists?(:airports, :city_id)
      add_reference :airports, :city, foreign_key: true, null: true
    end

    # Verify no null values before setting not null (seed should have populated city_id)
    if Airport.where(city_id: nil).exists?
      raise "There are airports with null city_id values. Ensure the seed populates city_id before running this migration."
    end

    # Change city_id to not null
    change_column_null :airports, :city_id, false
  end
end