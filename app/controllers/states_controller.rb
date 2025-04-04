class StatesController < ApplicationController
  def index
    @states = State.order(:name)
    set_meta_tags title: "Flight Schools by State | Pilot Training Near Me",
                  description: "Find flight schools across the US, state by state.",
                  keywords: "flight schools, pilot training, aviation schools"
  end

  def show
    @state = State.find_by!(abbreviation: params[:abbreviation])
    @airports = @state.airports.order(:city) if @state.airports.any?
    set_meta_tags title: "Flight Schools in #{@state.name} (#{@state.abbreviation}) | Pilot Training Near Me",
                  description: "Explore flight schools in #{@state.name} (#{@state.abbreviation}) for pilot training and aviation education.",
                  keywords: "flight schools #{@state.name}, pilot training #{@state.abbreviation}, aviation schools #{@state.name}"
  end
end