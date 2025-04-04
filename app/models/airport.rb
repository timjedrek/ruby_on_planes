class Airport < ApplicationRecord
  belongs_to :state
  has_and_belongs_to_many :cities # Replaces belongs_to :city and nearby_towns
  has_many :schools, dependent: :restrict_with_error

  validates :code, :name, presence: true
  validates :code, uniqueness: true
  validates :icao_code, uniqueness: true, allow_nil: true
end