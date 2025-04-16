class CreateContactPeople < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_people do |t|
      t.string :name
      t.string :title
      t.string :phone
      t.string :email
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
