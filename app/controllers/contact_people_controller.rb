class ContactPeopleController < ApplicationController
  before_action :set_school
  before_action :set_contact_person, only: [:update, :destroy]

  def create
    @contact_person = @school.contact_people.build(contact_person_params)

    respond_to do |format|
      if @contact_person.save
        format.json { render json: { id: @contact_person.id, success: true }, status: :created }
      else
        format.json { 
          error_messages = @contact_person.errors.full_messages.join(", ")
          render json: { success: false, message: error_messages }, status: :unprocessable_entity 
        }
      end
    end
  end

  def update
    respond_to do |format|
      if @contact_person.update(contact_person_params)
        format.json { render json: { id: @contact_person.id, success: true }, status: :ok }
      else
        format.json { 
          error_messages = @contact_person.errors.full_messages.join(", ")
          render json: { success: false, message: error_messages }, status: :unprocessable_entity 
        }
      end
    end
  end

  def destroy
    @contact_person.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_school
    Rails.logger.debug "Contact People Controller params: #{params.inspect}"
    
    begin
      @airport = Airport.find_by(code: params[:airport_code].upcase)
      Rails.logger.debug "Found airport: #{@airport.inspect}"
      
      if @airport.nil?
        Rails.logger.error "Airport not found with code: #{params[:airport_code]}"
        return render json: { success: false, message: "Airport not found with code: #{params[:airport_code]}" }, status: :not_found
      end
      
      @school = School.find_by_slug_or_id_in_airport(params[:school_id], @airport.id)
      Rails.logger.debug "Found school: #{@school.inspect}"
      
      if @school.nil?
        Rails.logger.error "School not found with slug or ID: #{params[:school_id]}"
        return render json: { success: false, message: "School not found with slug or ID: #{params[:school_id]}" }, status: :not_found
      end
    rescue => e
      Rails.logger.error "Error in set_school: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      return render json: { success: false, message: "Error finding school or airport: #{e.message}" }, status: :not_found
    end
  end

  def set_contact_person
    begin
      @contact_person = @school.contact_people.find(params[:id])
      Rails.logger.debug "Found contact person: #{@contact_person.inspect}"
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Contact person not found with id: #{params[:id]}"
      return render json: { success: false, message: "Contact person not found" }, status: :not_found
    end
  end

  def contact_person_params
    begin
      params.require(:contact_person).permit(:name, :title, :email, :phone)
    rescue ActionController::ParameterMissing => e
      Rails.logger.error "Parameter missing: #{e.message}"
      return render json: { success: false, message: "Contact person parameters are missing" }, status: :bad_request
    end
  end
end 