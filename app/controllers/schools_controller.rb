class SchoolsController < ApplicationController
  def show
    @airport = Airport.find_by!(code: params[:airport_code].upcase)
    @school = @airport.schools.find(params[:id])
    @state = @airport.state
    set_meta_tags title: "#{@school.name} at #{@airport.name} | Pilot Training Near Me",
                  description: "Learn about #{@school.name} flight school at #{@airport.name} in #{@airport.city.name}, #{@state.abbreviation}.",
                  keywords: "#{@school.name}, flight school #{@airport.code}, pilot training #{@airport.city.name}"
  end
end