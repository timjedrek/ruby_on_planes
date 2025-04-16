class AddDescriptionToAirports < ActiveRecord::Migration[8.0]
  def change
    add_column :airports, :description, :text
  end
end
