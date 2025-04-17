class SchoolsController < ApplicationController
  before_action :set_airport
  before_action :set_school, only: [:show, :edit, :update]

  def show
    @state = @airport.state
    @contact_people = @school.contact_people.order(:name)
    set_meta_tags title: "#{@school.name} at #{@airport.name} | Pilot Training Near Me",
                  description: "Learn about #{@school.name} at #{@airport.name} in #{@airport.city.name}, #{@state.abbreviation}.",
                  keywords: "flight school #{@school.name}, pilot training #{@airport.code}, #{@airport.city.name} aviation"
  end

  def edit
    @school.contact_people.build if @school.contact_people.empty?
  end

  def update
    Rails.logger.debug "UPDATE PARAMS: #{params.inspect}"
    
    respond_to do |format|
      if @school.update(school_params)
        # Store the redirect URL for use in the Turbo Stream response
        redirect_url = airport_school_path(@airport.code, @school)
        
        format.html { redirect_to redirect_url, notice: 'School was successfully updated.' }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.redirect(redirect_url)
        }
        format.json { render json: { success: true, redirect_url: redirect_url } }
      else
        Rails.logger.debug "School errors: #{@school.errors.full_messages.inspect}"
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @school.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_airport
    @airport = Airport.find_by(code: params[:airport_code].upcase)
    
    if @airport.nil?
      Rails.logger.error "Could not find airport with code: #{params[:airport_code]}"
      render plain: "Could not find airport with code: #{params[:airport_code]}", status: :not_found
    end
  end
  
  def set_school
    @school = @airport.schools.find_by_slug_or_id(params[:id])
    
    if @school.nil?
      Rails.logger.error "Could not find school with ID or slug: #{params[:id]}"
      render plain: "Could not find school with ID or slug: #{params[:id]}", status: :not_found
    end
  end

  def school_params
    params.require(:school).permit(
      :name, :website, :phone, :description, :est_planes, :est_cfis, :date_established,
      :part_141, :part_61, :accelerated_programs, :examining_authority, :featured,
      training_types: [],
      contact_people_attributes: [:id, :name, :title, :phone, :email, :_destroy]
    )
  end
end