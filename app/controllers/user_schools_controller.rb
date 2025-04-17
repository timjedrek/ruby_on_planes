class UserSchoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_school, only: [ :show, :verify_review ]
  before_action :authorize_school_owner, only: [ :show, :verify_review ]
  before_action :set_review, only: [ :verify_review ]

  def index
    @schools = current_user.schools.includes(:airport, :reviews).order(name: :asc)
  end

  def show
    @reviews = @school.reviews.includes(:user).order(created_at: :desc)
  end

  def verify_review
    @review = @school.reviews.find(params[:review_id])
    @review.update(verified: true)
    redirect_to user_school_path(@school), notice: "Review has been marked as verified."
  end

  private

  def set_school
    @school = School.find_by_slug_or_id(params[:id])
    redirect_to user_schools_path, alert: "School not found" unless @school
  end

  def authorize_school_owner
    unless current_user.owns_school?(@school)
      redirect_to user_schools_path, alert: "You don't have permission to manage this school"
    end
  end

  def set_review
    @review = @school.reviews.find(params[:review_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to user_school_path(@school), alert: "Review not found"
  end
end
