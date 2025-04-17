class UserReviewsController < ApplicationController
  before_action :authenticate_user!

  def index
    @reviews = current_user.reviews.includes(:school).order(created_at: :desc)
  end
end
