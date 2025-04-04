class RemoveCityIdAndNearbyTownsFromAirports < ActiveRecord::Migration[8.0]
  def change
    remove_reference :airports, :city, foreign_key: true
    remove_column :airports, :nearby_towns, :string, array: true, default: [], null: false
  end
end