class StatesController < ApplicationController
  def index
    sort_param = params[:sort] || "name_asc"

    # Base query with school counts
    states_query = State.left_joins(airports: :schools)
                        .select("states.*, COUNT(DISTINCT schools.id) as school_count")
                        .group("states.id")

    # Apply sorting
    @states = case sort_param
    when "name_asc"
                states_query.order("states.name ASC")
    when "name_desc"
                states_query.order("states.name DESC")
    when "schools_asc"
                states_query.order("school_count ASC, states.name ASC")
    when "schools_desc"
                states_query.order("school_count DESC, states.name ASC")
    else
                states_query.order("states.name ASC")
    end

    @current_sort = sort_param

    set_meta_tags title: "Flight Schools by State | Pilot Training Near Me",
                  description: "Find flight schools across the US, state by state.",
                  keywords: "flight schools, pilot training, aviation schools"
  end

  def show
    @state = State.find_by!(abbreviation: params[:abbreviation].upcase)

    # Handle city sorting
    city_sort = params[:city_sort] || "name_asc"

    # Base query with airport counts
    city_query = @state.cities
                      .left_joins(:airports)
                      .select("cities.*, COUNT(DISTINCT airports.id) as airport_count")
                      .group("cities.id")

    # Apply sorting
    @cities = case city_sort
    when "name_asc"
                city_query.order("cities.name ASC")
    when "name_desc"
                city_query.order("cities.name DESC")
    when "airports_asc"
                city_query.order("airport_count ASC, cities.name ASC")
    when "airports_desc"
                city_query.order("airport_count DESC, cities.name ASC")
    else
                city_query.order("cities.name ASC")
    end

    @current_city_sort = city_sort

    # Get airports with school counts (no sorting)
    @airports = @state.airports
                     .left_joins(:schools)
                     .select("airports.*, COUNT(DISTINCT schools.id) as school_count")
                     .group("airports.id")
                     .order("airports.name ASC")

    set_meta_tags title: "Flight Schools in #{@state.name} (#{@state.abbreviation}) | Pilot Training Near Me",
                  description: "Explore flight schools in #{@state.name} (#{@state.abbreviation}) for pilot training and aviation education.",
                  keywords: "flight schools #{@state.name}, pilot training #{@state.abbreviation}, aviation schools #{@state.name}"
  end
end
