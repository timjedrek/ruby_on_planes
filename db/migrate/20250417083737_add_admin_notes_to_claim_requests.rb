class AddAdminNotesToClaimRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :claim_requests, :admin_notes, :text
  end
end
