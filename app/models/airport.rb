class Airport < ApplicationRecord
  belongs_to :state
  has_many :schools, dependent: :restrict_with_error

  validates :code, :name, :city, presence: true
  validates :code, uniqueness: true
end