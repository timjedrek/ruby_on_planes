# db/seeds.rb

# Seed 1 state
states_data = [
  { name: "Arizona", abbreviation: "AZ" }
]

State.destroy_all
states_data.each do |state_data|
  State.create!(state_data)
end
puts "Seeded #{State.count} states."

# Seed 1 city with 2 nearby towns
cities_data = [
  { name: "Phoenix", state_abbr: "AZ" },
  { name: "Tempe", state_abbr: "AZ" },
  { name: "Mesa", state_abbr: "AZ" }
]

City.destroy_all
cities_data.each do |city_data|
  state = State.find_by(abbreviation: city_data[:state_abbr])
  City.create!(name: city_data[:name], state: state)
end
puts "Seeded #{City.count} cities."

# Set nearby cities relationships
phoenix = City.find_by(name: "Phoenix", state: State.find_by(abbreviation: "AZ"))
tempe = City.find_by(name: "Tempe", state: State.find_by(abbreviation: "AZ"))
mesa = City.find_by(name: "Mesa", state: State.find_by(abbreviation: "AZ"))

# Clean up existing nearby city relationships
NearbyCity.destroy_all

# Phoenix is near Tempe and Mesa
NearbyCity.create!(city: phoenix, nearby_city: tempe)
NearbyCity.create!(city: phoenix, nearby_city: mesa)

# Tempe is near Phoenix and Mesa
NearbyCity.create!(city: tempe, nearby_city: phoenix)
NearbyCity.create!(city: tempe, nearby_city: mesa)

# Mesa is near Phoenix and Tempe
NearbyCity.create!(city: mesa, nearby_city: phoenix)
NearbyCity.create!(city: mesa, nearby_city: tempe)

puts "Set up nearby city relationships."

# Seed airports for each city
airports_data = [
  { code: "PHX", icao_code: "KPHX", name: "Phoenix Sky Harbor International Airport", state_abbr: "AZ", city_name: "Phoenix" },
  { code: "AZA", icao_code: "KIWA", name: "Phoenix-Mesa Gateway Airport", state_abbr: "AZ", city_name: "Mesa" },
  { code: "CHD", icao_code: "KCHD", name: "Chandler Municipal Airport", state_abbr: "AZ", city_name: "Tempe" },
  { code: "FFZ", icao_code: "KFFZ", name: "Falcon Field Airport", state_abbr: "AZ", city_name: "Mesa" }
]

Airport.destroy_all
airports_data.each do |airport_data|
  state = State.find_by(abbreviation: airport_data[:state_abbr])
  city = City.find_by(name: airport_data[:city_name], state: state)
  raise "City not found for airport #{airport_data[:code]}" unless city

  airport_attrs = airport_data.except(:city_name, :state_abbr)
  begin
    Airport.create!(airport_attrs.merge(state: state, city: city))
  rescue ActiveRecord::RecordInvalid => e
    puts "Failed to create airport: #{airport_attrs[:name]} (#{airport_attrs[:code]}) - #{e.message}"
    raise
  end
end
puts "Seeded #{Airport.count} airports."

# Seed 1 school with all fields
schools_data = [
  {
    name: "SimpliFly",
    airport_code: "FFZ",
    website: "https://simpliflyco.com",
    phone: "480-555-1234",
    description: "SimpliFly offers top-notch flight training at Falcon Field, with a focus on personalized instruction.",
    est_planes: 10,
    est_cfis: 5,
    part_141: true,
    part_61: true,
    training_types: ["private", "commercial", "instrument"],
    accelerated_programs: true,
    examining_authority: false,
    date_established: Date.new(2015, 6, 1),
    featured: true,
    approved: true
  },
  {
    name: "Sky Harbor Flight School",
    airport_code: "PHX",
    website: "https://skyharborflightschool.com",
    phone: "602-555-1234",
    description: "Sky Harbor Flight School offers training in the heart of Phoenix with access to a major international airport.",
    est_planes: 15,
    est_cfis: 12,
    part_141: true,
    part_61: true,
    training_types: ["private", "commercial", "instrument", "multi", "atp"],
    accelerated_programs: false,
    examining_authority: true,
    date_established: Date.new(2010, 1, 15),
    featured: true,
    approved: true
  },
  {
    name: "Mesa Flight Academy",
    airport_code: "AZA",
    website: "https://mesaflightacademy.com",
    phone: "480-555-5678",
    description: "Mesa Flight Academy provides comprehensive flight training in the East Valley.",
    est_planes: 8,
    est_cfis: 6,
    part_141: false,
    part_61: true,
    training_types: ["private", "commercial", "instrument", "multi"],
    accelerated_programs: true,
    examining_authority: false,
    date_established: Date.new(2018, 3, 15),
    featured: false,
    approved: true
  },
  {
    name: "Chandler Aviation",
    airport_code: "CHD",
    website: "https://chandleraviation.com",
    phone: "480-555-9012",
    description: "Chandler Aviation specializes in accelerated flight training programs in a relaxed environment.",
    est_planes: 5,
    est_cfis: 3,
    part_141: false,
    part_61: true,
    training_types: ["private", "instrument"],
    accelerated_programs: false,
    examining_authority: false,
    date_established: Date.new(2020, 1, 10),
    featured: false,
    approved: true
  }
]

School.destroy_all
schools_data.each do |school_data|
  airport = Airport.find_by(code: school_data[:airport_code])
  School.create!(
    name: school_data[:name],
    airport: airport,
    website: school_data[:website],
    phone: school_data[:phone],
    description: school_data[:description],
    est_planes: school_data[:est_planes],
    est_cfis: school_data[:est_cfis],
    part_141: school_data[:part_141],
    part_61: school_data[:part_61],
    training_types: school_data[:training_types],
    accelerated_programs: school_data[:accelerated_programs],
    examining_authority: school_data[:examining_authority],
    date_established: school_data[:date_established],
    featured: school_data[:featured],
    approved: school_data[:approved]
  )
end
puts "Seeded #{School.count} schools."