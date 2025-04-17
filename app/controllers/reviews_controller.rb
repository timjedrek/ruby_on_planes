class ReviewsController < ApplicationController
  before_action :authenticate_user!, only: [ :edit, :update, :destroy ]
  before_action :set_school
  before_action :set_review, only: [ :edit, :update, :destroy ]
  before_action :authorize_review, only: [ :edit, :update, :destroy ]

  def new
    @review = @school.reviews.new
  end

  def create
    @review = @school.reviews.new(review_params)

    # Associate with user if logged in
    if user_signed_in?
      @review.user = current_user
    end

    if @review.save
      redirect_to airport_school_path(@school.airport.code, @school), notice: "Thank you for your review! It has been submitted successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to airport_school_path(@school.airport.code, @school), notice: "Your review has been updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    redirect_to airport_school_path(@school.airport.code, @school), notice: "Your review has been deleted successfully."
  end

  private

  def set_school
    @school = School.find_by_slug_or_id(params[:school_id])
  end

  def set_review
    @review = @school.reviews.find(params[:id])
  end

  def review_params
    if user_signed_in?
      params.require(:review).permit(:rating, :title, :comment)
    else
      params.require(:review).permit(:rating, :title, :comment, :reviewer_name, :reviewer_email)
    end
  end

  def authorize_review
    unless current_user == @review.user || current_user&.admin?
      redirect_to airport_school_path(@school.airport.code, @school), alert: "You are not authorized to perform this action."
    end
  end
end
