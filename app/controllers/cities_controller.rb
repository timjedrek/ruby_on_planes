class CitiesController < ApplicationController
  def show
    @state = State.find_by!(abbreviation: params[:state_abbreviation].upcase)
    @city = @state.cities.find_by!(name: params[:name])
    @airports = @city.airports.order(:name)
    # Nearby airports: from cities that share any of this city's airports
    @nearby_airports = Airport.joins(:cities)
                              .where(cities: { state_id: @state.id })
                              .where.not(id: @airports.pluck(:id)) # Exclude city's own airports
                              .where(cities: { id: @city.airports.flat_map(&:cities).pluck(:id) })
                              .order(:name)
                              .distinct
    set_meta_tags title: "Flight Schools in #{@city.name}, #{@state.abbreviation} | Pilot Training Near Me",
                  description: "Explore flight schools in #{@city.name}, #{@state.name} and nearby areas.",
                  keywords: "flight schools #{@city.name}, pilot training #{@state.abbreviation}"
  end
end