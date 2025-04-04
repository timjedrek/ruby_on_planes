class AirportsController < ApplicationController
  def index
    @state = State.find_by!(abbreviation: params[:state].upcase) if params[:state].present?
    @airports = @state ? @state.airports.joins(:city).order("cities.name") : Airport.joins(:city).order("cities.name")
    @title = @state ? "All Airports in #{@state.name} (#{@state.abbreviation})" : "All Airports"
    set_meta_tags title: "#{@title} | Pilot Training Near Me",
                  description: "Browse all airports#{@state ? " in #{@state.name}" : ""} for flight training.",
                  keywords: "airports#{@state ? " #{@state.name}" : ""}, flight schools, pilot training"
  end
end