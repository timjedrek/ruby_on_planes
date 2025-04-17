class ClaimRequest < ApplicationRecord
  belongs_to :user
  belongs_to :school

  validates :message, presence: true
  validates :status, inclusion: { in: %w[pending approved rejected] }
  validates :user_id, uniqueness: { scope: :school_id,
                                  message: "already has a pending or processed claim for this school" }

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }

  def approve!
    transaction do
      update!(status: "approved")
      # Add the user as an owner of the school
      school.users << user unless school.users.include?(user)
    end
  end

  def approved!
    approve!
  end

  def reject!
    update!(status: "rejected")
  end

  def rejected!
    reject!
  end

  def pending?
    status == "pending"
  end

  def approved?
    status == "approved"
  end

  def rejected?
    status == "rejected"
  end

  def relationship
    message
  end
end
