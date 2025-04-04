class State < ApplicationRecord
  has_many :airports, dependent: :restrict_with_error
  has_many :cities, dependent: :restrict_with_error

  validates :name, :abbreviation, presence: true
  validates :abbreviation, uniqueness: true, length: { is: 2 }
end