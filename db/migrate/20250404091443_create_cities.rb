class CreateCities < ActiveRecord::Migration[8.0]
  def change
    create_table :cities do |t|
      t.string :name
      t.references :state, null: false, foreign_key: true

      t.timestamps
    end
    add_index :cities, [:state_id, :name], unique: true # Prevents duplicate cities in a state
  end
end
