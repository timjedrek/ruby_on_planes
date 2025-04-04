class Airport < ApplicationRecord
  belongs_to :state
  belongs_to :city
  has_many :schools, dependent: :restrict_with_error

  validates :code, :name, presence: true
  validates :code, uniqueness: true
  validates :icao_code, uniqueness: true, allow_nil: true
end