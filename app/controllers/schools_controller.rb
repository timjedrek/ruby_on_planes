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
    Rails.logger.debug "UPDATE PARAMS: #{params.inspect}"
    
    # Try to find airport using different parameter names
    airport_code = params[:airport_code] || params[:code]
    
    # Log what we're looking for
    Rails.logger.debug "Looking for airport with code: #{airport_code.inspect}"
    
    if airport_code.blank?
      Rails.logger.error "Airport code parameter is missing or blank"
      return render plain: "Airport code parameter is missing", status: :bad_request
    end
    
    @airport = Airport.find_by(code: airport_code.upcase)
    
    if @airport.nil?
      Rails.logger.error "Could not find airport with code: #{airport_code.upcase}"
      return render plain: "Could not find airport with code: #{airport_code.upcase}", status: :not_found
    end
    
    @school = @airport.schools.find(params[:id])
    
    Rails.logger.debug "School params: #{school_params.inspect}"
    
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

  def school_params
    params.require(:school).permit(
      :name, :website, :phone, :description, :est_planes, :est_cfis, :date_established,
      :part_141, :part_61, :accelerated_programs, :examining_authority, :featured,
      training_types: [],
      contact_people_attributes: [:id, :name, :title, :phone, :email, :_destroy]
    )
  end
end