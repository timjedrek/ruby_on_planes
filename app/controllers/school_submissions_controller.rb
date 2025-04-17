class SchoolSubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_airports, only: [ :new, :create ]
  before_action :set_school, only: [ :claim_form, :claim ]

  def new
    @school = School.new
    @school.contact_people.build if @school.contact_people.empty?
  end

  def create
    @school = School.new(school_params)
    @school.approved = false  # New submissions start as unapproved

    if @school.save
      # Associate the current user with the school
      @school.users << current_user

      # Notify admins (you could implement email notifications here)

      redirect_to airport_school_path(@school.airport.code, @school),
                  notice: "Thank you for your submission! Your school listing will be reviewed by our team and made public once approved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def claim_form
    if current_user.owns_school?(@school)
      redirect_to airport_school_path(@school.airport.code, @school),
                  alert: "You are already listed as an owner of this school."
      return
    end

    # Check if user already has a pending claim
    existing_claim = ClaimRequest.find_by(user: current_user, school: @school)
    if existing_claim && existing_claim.status == "pending"
      redirect_to airport_school_path(@school.airport.code, @school),
                  alert: "You already have a pending claim request for this school."
      return
    end

    render :claim
  end

  def claim
    if current_user.owns_school?(@school)
      redirect_to airport_school_path(@school.airport.code, @school),
                  alert: "You are already listed as an owner of this school."
      return
    end

    # Create a claim request
    claim_request = ClaimRequest.new(
      user: current_user,
      school: @school,
      message: params[:message],
      status: "pending"
    )

    if claim_request.save
      # Notify admins (you could implement email notifications here)

      redirect_to airport_school_path(@school.airport.code, @school),
                  notice: "Your claim request has been submitted and will be reviewed by our team."
    else
      flash.now[:alert] = "There was an error with your claim request: #{claim_request.errors.full_messages.join(", ")}"
      render :claim, status: :unprocessable_entity
    end
  end

  private

  def set_airports
    @airports = Airport.order(:name)
  end

  def set_school
    @school = School.find_by_slug_or_id(params[:id])

    if @school.nil?
      redirect_to root_path, alert: "School not found."
    end
  end

  def school_params
    params.require(:school).permit(
      :name, :website, :phone, :description, :airport_id, :est_planes, :est_cfis,
      :date_established, :part_141, :part_61, :accelerated_programs, :examining_authority,
      training_types: [],
      contact_people_attributes: [ :id, :name, :title, :phone, :email, :_destroy ]
    )
  end
end
