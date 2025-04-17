class Admin::DashboardController < Admin::BaseController
  def index
    @page_title = "Admin Dashboard"
    @pending_claim_requests_count = ClaimRequest.pending.count
    @unpublished_reviews_count = Review.where(published: false).count
    @unapproved_schools_count = School.where(approved: false).count
  end
end
