class CreateAirports < ActiveRecord::Migration[8.0]
  def change
    create_table :airports do |t|
      t.string :code
      t.string :name
      t.string :city
      t.string :nearby_towns
      t.references :state, null: false, foreign_key: true

      t.timestamps
    end
    add_index :airports, :code, unique: true
    add_index :airports, [:state_id, :city]
  end
end
