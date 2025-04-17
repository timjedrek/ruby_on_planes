class Admin::ClaimRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_claim_request, only: [ :show, :approve, :reject ]

  def index
    @claim_requests = ClaimRequest.includes(:user, :school).order(created_at: :desc)

    if params[:filter] == "pending"
      @claim_requests = @claim_requests.pending
    elsif params[:filter] == "approved"
      @claim_requests = @claim_requests.approved
    elsif params[:filter] == "rejected"
      @claim_requests = @claim_requests.rejected
    end

    @filter = params[:filter]
  end

  def show
  end

  def approve
    @claim_request.approve!
    redirect_to admin_claim_requests_path, notice: "Claim request has been approved. User is now an owner of the school."
  end

  def reject
    @claim_request.reject!
    redirect_to admin_claim_requests_path, notice: "Claim request has been rejected."
  end

  private

  def set_claim_request
    @claim_request = ClaimRequest.find(params[:id])
  end

  def ensure_admin
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
