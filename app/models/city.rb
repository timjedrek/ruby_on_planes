class City < ApplicationRecord
  belongs_to :state
  has_many :airports, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: { scope: :state_id }

  # Fetch nearby cities as City objects
  def nearby_city_records
    City.where(name: nearby_cities, state_id: state_id)
  end
end