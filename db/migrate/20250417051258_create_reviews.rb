class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.decimal :rating, precision: 3, scale: 1, null: false
      t.text :comment, null: false
      t.string :reviewer_name
      t.string :reviewer_email
      t.references :user, null: true, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.boolean :published, default: true
      t.boolean :verified, default: false
      t.string :title

      t.timestamps
    end
  end
end
