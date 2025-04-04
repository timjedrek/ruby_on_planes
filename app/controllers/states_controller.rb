class StatesController < ApplicationController
  def index
    @states = State.order(:name)
  end

  def show
    @state = State.find_by!(abbreviation: params[:abbreviation])
    @airports = @state.airports.order(:city) if @state.airports.any? # Placeholder for now
  end
end
