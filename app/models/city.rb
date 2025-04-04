class City < ApplicationRecord
  belongs_to :state
  has_and_belongs_to_many :airports # Replaces has_many :airports

  validates :name, presence: true
  validates :name, uniqueness: { scope: :state_id }
end