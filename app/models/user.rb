class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :reviews, dependent: :nullify
  has_many :user_schools, dependent: :destroy
  has_many :schools, through: :user_schools

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }, allow_blank: true

  def admin?
    role == "admin"
  end

  def owns_school?(school)
    schools.include?(school)
  end
end
