class School < ApplicationRecord
  belongs_to :airport
  has_one :city, through: :airport
  has_one :state, through: :airport

  validates :name, presence: true
  validates :est_planes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :est_cfis, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :training_types, presence: true, if: -> { training_types.present? }
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :phone, format: { with: /\A\+?\d{1,3}[-.\s]?\(?\d{1,3}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}\z/, message: "must be a valid phone number" }, allow_blank: true
end