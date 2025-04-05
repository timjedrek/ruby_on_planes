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

# Set nearby_cities for Phoenix
phoenix = City.find_by(name: "Phoenix", state: State.find_by(abbreviation: "AZ"))
tempe = City.find_by(name: "Tempe", state: State.find_by(abbreviation: "AZ"))
mesa = City.find_by(name: "Mesa", state: State.find_by(abbreviation: "AZ"))

phoenix.update!(nearby_cities: ["Tempe", "Mesa"])
tempe.update!(nearby_cities: ["Phoenix"])
mesa.update!(nearby_cities: ["Phoenix"])

# Seed 1 airport
airports_data = [
  { code: "PHX", icao_code: "KPHX", name: "Phoenix Sky Harbor International Airport", state_abbr: "AZ", city_name: "Phoenix" }
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

# Seed 1 school with contact info
schools_data = [
  { name: "SimpliFly", airport_code: "PHX", website: "https://simpliflyco.com", phone: "480-555-1234" }
]

School.destroy_all
schools_data.each do |school_data|
  airport = Airport.find_by(code: school_data[:airport_code])
  School.create!(
    name: school_data[:name],
    airport: airport,
    website: school_data[:website],
    phone: school_data[:phone]
  )
end
puts "Seeded #{School.count} schools."