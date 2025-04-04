class CreateSchools < ActiveRecord::Migration[8.0]
  def change
    create_table :schools do |t|
      t.string :name
      t.string :website
      t.string :phone
      t.references :airport, null: false, foreign_key: true

      t.timestamps
    end
    add_index :schools, [:airport_id, :name], unique: true # No duplicate school names per airport
  end
end
