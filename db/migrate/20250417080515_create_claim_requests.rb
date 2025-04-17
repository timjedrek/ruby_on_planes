class CreateClaimRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :claim_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :school, null: false, foreign_key: true
      t.text :message, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :claim_requests, [ :user_id, :school_id ], unique: true
  end
end
