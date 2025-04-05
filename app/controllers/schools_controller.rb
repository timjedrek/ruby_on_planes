class SchoolsController < ApplicationController
  def show
    @airport = Airport.find_by!(code: params[:airport_code].upcase)
    @school = @airport.schools.find(params[:id])
    @state = @airport.state
    set_meta_tags title: "#{@school.name} at #{@airport.name} | Pilot Training Near Me",
                  description: "Learn about #{@school.name} at #{@airport.name} in #{@airport.city.name}, #{@state.abbreviation}.",
                  keywords: "flight school #{@school.name}, pilot training #{@airport.code}, #{@airport.city.name} aviation"
  end
end