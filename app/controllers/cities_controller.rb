class CitiesController < ApplicationController
  before_action :set_state
  before_action :set_city, only: [:show, :edit, :update, :destroy]
  
  def show
    decoded_name = CGI.unescape(params[:name]).titleize
    @city = @state.cities.where("LOWER(name) = LOWER(?)", decoded_name).first
    unless @city
      redirect_to state_path(@state.abbreviation), 
                  alert: "City '#{decoded_name}' was not found in #{@state.name}."
      return
    end
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
  
  def new
    @city = City.new(state: @state)
    @cities = @state.cities.order(:name)
  end
  
  def create
    @city = City.new(city_params)
    @city.state = @state
    
    if @city.save
      # Add nearby cities if selected
      if params[:nearby_city_ids].present?
        params[:nearby_city_ids].each do |nearby_city_id|
          NearbyCity.create(city: @city, nearby_city_id: nearby_city_id)
        end
      end
      
      redirect_to state_city_path(@state.abbreviation, @city.name), notice: "City was successfully created."
    else
      @cities = @state.cities.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @cities = @state.cities.where.not(id: @city.id).order(:name)
    @selected_nearby_city_ids = @city.nearby_cities.pluck(:id)
  end

  def update
    if @city.update(city_params)
      # Update nearby cities
      @city.nearby_city_relationships.destroy_all
      if params[:nearby_city_ids].present?
        params[:nearby_city_ids].each do |nearby_city_id|
          NearbyCity.create(city: @city, nearby_city_id: nearby_city_id)
        end
      end
      
      redirect_to state_city_path(@state.abbreviation, @city.name), notice: "City was successfully updated."
    else
      @cities = @state.cities.where.not(id: @city.id).order(:name)
      @selected_nearby_city_ids = params[:nearby_city_ids]&.map(&:to_i) || []
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @city.destroy!
      redirect_to state_path(@state.abbreviation), notice: 'City was successfully deleted.'
    rescue => e
      redirect_to state_city_path(@state.abbreviation, @city.name), 
                  alert: 'Unable to delete this city. It may have associated records.'
    end
  end
  
  private
  
  def set_state
    @state = State.find_by!(abbreviation: params[:state_abbreviation].upcase)
  end

  def set_city
    decoded_name = CGI.unescape(params[:name]).titleize
    @city = @state.cities.where("LOWER(name) = LOWER(?)", decoded_name).first
    unless @city
      redirect_to state_path(@state.abbreviation), 
                  alert: "City '#{decoded_name}' was not found in #{@state.name}."
      return
    end
  end
  
  def city_params
    params.require(:city).permit(:name)
  end
end