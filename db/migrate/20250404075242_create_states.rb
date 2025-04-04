class CreateStates < ActiveRecord::Migration[8.0]
  def change
    create_table :states do |t|
      t.string :name
      t.string :abbreviation
      t.timestamps
    end
    add_index :states, :abbreviation, unique: true
  end
end
