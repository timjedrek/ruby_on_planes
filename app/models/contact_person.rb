class ContactPerson < ApplicationRecord
  belongs_to :school

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }, allow_blank: true
  validates :phone, format: { with: /\A\+?\d{1,3}[-.\s]?\(?\d{1,3}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}\z/, message: "must be a valid phone number" }, allow_blank: true
end
