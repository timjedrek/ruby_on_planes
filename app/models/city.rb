class City < ApplicationRecord
  belongs_to :state
  has_many :airports, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: { scope: :state_id } # "Springfield" OK in MO and IL
end