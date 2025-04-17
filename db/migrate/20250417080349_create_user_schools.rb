class CreateUserSchools < ActiveRecord::Migration[8.0]
  def change
    create_table :user_schools do |t|
      t.references :user, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_schools, [ :user_id, :school_id ], unique: true
  end
end
