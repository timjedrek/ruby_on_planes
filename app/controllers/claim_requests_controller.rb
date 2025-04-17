class ClaimRequestsController < ApplicationController
  before_action :authenticate_user!

  def index
    @page_title = "Your Claim Requests"
    @claim_requests = current_user.claim_requests.includes(school: [ :airport, :city, :state ]).order(created_at: :desc)
  end

  def show
    @claim_request = current_user.claim_requests.includes(school: [ :airport, :city, :state ]).find(params[:id])
    @page_title = "Claim Request Details"
  end
end
