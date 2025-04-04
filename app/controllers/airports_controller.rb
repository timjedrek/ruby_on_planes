class AirportsController < ApplicationController
  def index
    @state = State.find_by!(abbreviation: params[:state].upcase) if params[:state].present?
    @airports = @state ? @state.airports.joins(:cities).order("airports.name").distinct : Airport.joins(:cities).order("airports.name").distinct
    @title = @state ? "All Airports in #{@state.name} (#{@state.abbreviation})" : "All Airports"
    set_meta_tags title: "#{@title} | Pilot Training Near Me",
                  description: "Browse all airports#{@state ? " in #{@state.name}" : ""} for flight training.",
                  keywords: "airports#{@state ? " #{@state.name}" : ""}, flight schools, pilot training"
  end

  def show
    @airport = Airport.find_by!(code: params[:code].upcase)
    @state = @airport.state
    primary_city = @airport.cities.first
    set_meta_tags title: "#{@airport.name} (#{@airport.code}) | Pilot Training Near Me",
                  description: "Explore flight schools at #{@airport.name} in #{primary_city&.name || 'multiple cities'}, #{@state.abbreviation}.",
                  keywords: "flight schools #{@airport.name}, pilot training #{@airport.code}, #{primary_city&.name || 'aviation'}"
  end
end