class Review < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :school

  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :comment, presence: true, length: { minimum: 20, maximum: 2000 }
  validates :reviewer_name, presence: true, if: -> { user.blank? }
  validates :reviewer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { user.blank? }
  validates :title, presence: true, length: { maximum: 100 }

  scope :published, -> { where(published: true) }
  scope :verified, -> { where(verified: true) }
  scope :recent, -> { order(created_at: :desc) }

  after_save :update_school_average_rating
  after_destroy :update_school_average_rating

  def reviewer_display_name
    if user.present?
      user.email.split("@").first
    else
      reviewer_name
    end
  end

  private

  def update_school_average_rating
    # Only count published reviews in the average
    published_reviews = school.reviews.where(published: true)
    if published_reviews.any?
      avg = published_reviews.average(:rating).to_f.round(1)
      school.update_column(:avg_rating, avg)
    else
      school.update_column(:avg_rating, nil)
    end
  end
end
