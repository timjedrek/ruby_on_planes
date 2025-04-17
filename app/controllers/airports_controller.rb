class AirportsController < ApplicationController
  before_action :set_airport, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_admin, only: [ :edit, :update, :destroy ]

  def index
    @state = State.find_by!(abbreviation: params[:state].upcase) if params[:state].present?

    # Base query
    base_query = @state ? @state.airports : Airport.all

    # Apply sorting
    case params[:sort]
    when "name"
      @airports = base_query.order(:name)
    when "schools"
      @airports = base_query.left_joins(:schools)
                           .group(:id)
                           .order(Arel.sql("COUNT(schools.id) DESC, airports.code"))
    when "code", nil, ""
      @airports = base_query.order(:code)
    else
      @airports = base_query.order(:code)
    end

    @title = @state ? "All Airports in #{@state.name} (#{@state.abbreviation})" : "All Airports"
    set_meta_tags title: "#{@title} | Pilot Training Near Me",
                  description: "Browse all airports#{@state ? " in #{@state.name}" : ""} for flight training.",
                  keywords: "airports#{@state ? " #{@state.name}" : ""}, flight schools, pilot training"
  end

  def show
    @state = @airport.state

    # Show all schools to admins, but only approved schools to the public
    @schools = if user_signed_in? && current_user.admin?
                @airport.schools.order(:name)
    else
                @airport.schools.approved.order(:name)
    end

    # Get all nearby cities (both direct and inverse relationships)
    nearby_city_ids = (@airport.city.nearby_cities + @airport.city.inverse_nearby_cities).uniq.pluck(:id)

    # Get airports from nearby cities in the same state
    @nearby_airports = Airport.where(city_id: nearby_city_ids, state_id: @state.id)
                             .where.not(id: @airport.id)
                             .order(:name)
                             .distinct

    set_meta_tags title: "#{@airport.name} (#{@airport.code}) | Pilot Training Near Me",
                  description: "Explore flight schools at #{@airport.name} in #{@airport.city.name}, #{@state.abbreviation}.",
                  keywords: "flight schools #{@airport.name}, pilot training #{@airport.code}, #{@airport.city.name} aviation"
  end

  def edit
  end

  def update
    if @airport.update(airport_params)
      redirect_to airport_path(@airport.code), notice: "Airport was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @airport.destroy!
      redirect_to airports_path(state: @airport.state.abbreviation), notice: "Airport was successfully deleted."
    rescue => e
      redirect_to airport_path(@airport.code),
                  alert: "Unable to delete this airport. It may have associated schools."
    end
  end

  private

  def set_airport
    @airport = Airport.find_by!(code: params[:code].upcase)
    @state = @airport.state
  end

  def airport_params
    params.require(:airport).permit(:name, :code, :icao_code, :description)
  end

  def authorize_admin
    unless user_signed_in? && current_user.admin?
      redirect_to airport_path(@airport.code), alert: "You are not authorized to perform this action."
    end
  end
end
