class City < ApplicationRecord
  belongs_to :state
  has_many :airports, dependent: :restrict_with_error

  # For cities that this city lists as nearby
  has_many :nearby_city_relationships, class_name: 'NearbyCity', foreign_key: 'city_id'
  has_many :nearby_cities, through: :nearby_city_relationships, source: :nearby_city
  
  # For cities that list this city as nearby
  has_many :inverse_nearby_city_relationships, class_name: 'NearbyCity', foreign_key: 'nearby_city_id'
  has_many :inverse_nearby_cities, through: :inverse_nearby_city_relationships, source: :city

  validates :name, presence: true
  validates :name, uniqueness: { scope: :state_id }
end