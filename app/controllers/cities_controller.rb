class CitiesController < ApplicationController
  def show
    @state = State.find_by!(abbreviation: params[:state_abbreviation].upcase)
    @city = @state.cities.find_by!(name: params[:name])
    @airports = @city.airports.order(:name)
    # Nearby airports: from nearby cities in the same state
    @nearby_airports = Airport.where(city_id: @city.nearby_cities.pluck(:id), state_id: @state.id)
                              .where.not(id: @airports.pluck(:id))
                              .order(:name)
                              .distinct
    set_meta_tags title: "Flight Schools in #{@city.name}, #{@state.abbreviation} | Pilot Training Near Me",
                  description: "Explore flight schools in #{@city.name}, #{@state.name} and nearby areas.",
                  keywords: "flight schools #{@city.name}, pilot training #{@state.abbreviation}"
  end
end