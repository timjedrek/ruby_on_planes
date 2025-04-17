class Admin::ClaimRequestsController < Admin::BaseController
  before_action :set_claim_request, only: [ :show, :approve, :reject, :update_notes ]

  def index
    @page_title = "School Claim Requests"
    @status = params[:status]

    @claim_requests = ClaimRequest.includes(:user, school: [ :airport, :city, :state ])

    case @status
    when "pending"
      @claim_requests = @claim_requests.pending
    when "approved"
      @claim_requests = @claim_requests.approved
    when "rejected"
      @claim_requests = @claim_requests.rejected
    end

    @claim_requests = @claim_requests.order(created_at: :desc)
  end

  def show
    @page_title = "Claim Request Details"
  end

  def approve
    @claim_request.approved!

    # Grant school ownership to the user
    # Add the user as an owner of the school through the join table
    @claim_request.school.users << @claim_request.user unless @claim_request.school.users.include?(@claim_request.user)

    # Optional: Send notification to user
    # UserMailer.claim_request_approved(@claim_request).deliver_later

    redirect_to admin_claim_request_path(@claim_request), notice: "Claim request has been approved and school ownership has been granted."
  end

  def reject
    @claim_request.rejected!

    # Optional: Send notification to user
    # UserMailer.claim_request_rejected(@claim_request).deliver_later

    redirect_to admin_claim_request_path(@claim_request), notice: "Claim request has been rejected."
  end

  def update_notes
    if @claim_request.update(claim_request_params)
      redirect_to admin_claim_request_path(@claim_request), notice: "Admin notes updated successfully."
    else
      redirect_to admin_claim_request_path(@claim_request), alert: "Failed to update admin notes."
    end
  end

  private

  def set_claim_request
    @claim_request = ClaimRequest.includes(:user, school: [ :airport, :city, :state ]).find(params[:id])
  end

  def claim_request_params
    params.require(:claim_request).permit(:admin_notes)
  end
end
