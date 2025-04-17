class UserSchool < ApplicationRecord
  belongs_to :user
  belongs_to :school

  validates :user_id, uniqueness: { scope: :school_id }
end
