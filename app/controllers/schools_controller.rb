class SchoolsController < ApplicationController
  def show
    @airport = Airport.find_by!(code: params[:airport_code].upcase)
    @school = @airport.schools.find(params[:id])
    @state = @airport.state
    @contact_people = @school.contact_people.order(:name)
    set_meta_tags title: "#{@school.name} at #{@airport.name} | Pilot Training Near Me",
                  description: "Learn about #{@school.name} at #{@airport.name} in #{@airport.city.name}, #{@state.abbreviation}.",
                  keywords: "flight school #{@school.name}, pilot training #{@airport.code}, #{@airport.city.name} aviation"
  end

  def edit
    @airport = Airport.find_by!(code: params[:airport_code].upcase)
    @school = @airport.schools.find(params[:id])
    @school.contact_people.build if @school.contact_people.empty?
  end

  def update
    @airport = Airport.find_by!(code: params[:airport_code].upcase)
    @school = @airport.schools.find(params[:id])
    
    Rails.logger.debug "School params: #{school_params.inspect}"
    Rails.logger.debug "Contact people params: #{school_params[:contact_people_attributes].inspect}"
    
    if @school.update(school_params)
      redirect_to airport_school_path(@airport.code, @school), notice: 'School was successfully updated.'
    else
      Rails.logger.debug "School errors: #{@school.errors.full_messages.inspect}"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def school_params
    params.require(:school).permit(
      :name, :website, :phone, :description, :est_planes, :est_cfis, :date_established,
      :part_141, :part_61, :accelerated_programs, :examining_authority, :featured,
      training_types: [],
      contact_people_attributes: [:id, :name, :title, :phone, :email, :_destroy]
    )
  end
end