class AddNearbyCitiesToCities < ActiveRecord::Migration[7.1]
  def change
    add_column :cities, :nearby_cities, :string, array: true, default: [], null: false
  end
end