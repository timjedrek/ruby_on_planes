class Admin::ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_review, only: [ :edit, :update, :publish, :unpublish, :verify, :unverify, :destroy ]

  def index
    @reviews = Review.includes(:school, :user).order(created_at: :desc).page(params[:page]).per(20)

    if params[:filter] == "unpublished"
      @reviews = @reviews.where(published: false)
    elsif params[:filter] == "published"
      @reviews = @reviews.where(published: true)
    end

    @filter = params[:filter]
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to admin_reviews_path, notice: "Review was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def publish
    @review.update(published: true)
    redirect_to admin_reviews_path, notice: "Review has been published."
  end

  def unpublish
    @review.update(published: false)
    redirect_to admin_reviews_path, notice: "Review has been unpublished."
  end

  def verify
    @review.update(verified: true)
    redirect_to admin_reviews_path, notice: "Review has been verified."
  end

  def unverify
    @review.update(verified: false)
    redirect_to admin_reviews_path, notice: "Review verification has been removed."
  end

  def destroy
    @review.destroy
    redirect_to admin_reviews_path, notice: "Review has been deleted."
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :title, :comment, :published, :verified)
  end

  def ensure_admin
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
