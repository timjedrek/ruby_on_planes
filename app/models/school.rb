class School < ApplicationRecord
  belongs_to :airport
  has_one :city, through: :airport
  has_one :state, through: :airport
  has_many :contact_people, dependent: :destroy
  accepts_nested_attributes_for :contact_people, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :est_planes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :est_cfis, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :training_types, presence: true, if: -> { training_types.present? }
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :phone, format: { with: /\A\+?\d{1,3}[-.\s]?\(?\d{1,3}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}\z/, message: "must be a valid phone number" }, allow_blank: true

  # Generate a slug from the name
  def slug
    name.parameterize
  end

  # Override to_param to use slug instead of id
  def to_param
    slug
  end

  # Find by slug or ID
  def self.find_by_slug_or_id(param)
    # First try direct slug matching
    school = where("LOWER(REPLACE(name, ' ', '-')) = LOWER(?)", param).first
    
    # Then try to find by the slug-friendly version of the name
    if school.nil?
      school = where("LOWER(name) = LOWER(?)", param.gsub('-', ' ')).first
    end
    
    # Finally fall back to ID if slug not found and the param is numeric
    if school.nil? && param.to_i.to_s == param
      school = find_by(id: param)
    end
    
    school
  end
  
  # Find school by slug or ID within a specific airport
  def self.find_by_slug_or_id_in_airport(param, airport_id)
    schools = where(airport_id: airport_id)
    
    # First try direct slug matching
    school = schools.where("LOWER(REPLACE(name, ' ', '-')) = LOWER(?)", param).first
    
    # Then try to find by the slug-friendly version of the name
    if school.nil?
      school = schools.where("LOWER(name) = LOWER(?)", param.gsub('-', ' ')).first
    end
    
    # Finally fall back to ID if slug not found and the param is numeric
    if school.nil? && param.to_i.to_s == param
      school = schools.find_by(id: param)
    end
    
    school
  end
end