class NearbyCity < ApplicationRecord
  belongs_to :city
  belongs_to :nearby_city, class_name: 'City'
  
  validates :city_id, uniqueness: { scope: :nearby_city_id }
  validate :no_self_reference
  
  private
  
  def no_self_reference
    if city_id == nearby_city_id
      errors.add(:base, "A city cannot be nearby to itself")
    end
  end
end
