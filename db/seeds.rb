# db/seeds.rb
states = [
  { name: "Missouri", abbreviation: "MO" },
  { name: "Florida", abbreviation: "FL" },
  { name: "California", abbreviation: "CA" }
]
states.each { |s| State.create!(s) }

mo = State.find_by(abbreviation: "MO")
fl = State.find_by(abbreviation: "FL")

Airport.create!([
  { code: "STL", name: "St. Louis Lambert International Airport", city: "St. Louis", nearby_towns: ["Chesterfield", "Ballwin"], state: mo },
  { code: "MCO", name: "Orlando International Airport", city: "Orlando", nearby_towns: ["Winter Park"], state: fl }
])