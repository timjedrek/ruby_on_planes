class School < ApplicationRecord
  belongs_to :airport
  has_one :city, through: :airport
  has_one :state, through: :airport

  validates :name, presence: true
  validates :name, uniqueness: { scope: :airport_id } # Unique per airport
end