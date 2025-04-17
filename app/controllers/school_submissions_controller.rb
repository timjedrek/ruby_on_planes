class SchoolSubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_airports, only: [ :new, :create ]

  def new
    @school = School.new
    @school.contact_people.build
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

  def claim
    @school = School.find_by_slug_or_id(params[:id])

    if @school.nil?
      redirect_to root_path, alert: "School not found."
      return
    end

    if current_user.owns_school?(@school)
      redirect_to airport_school_path(@school.airport.code, @school),
                  alert: "You are already listed as an owner of this school."
      return
    end

    # Create a claim request (you would implement this model)
    ClaimRequest.create(
      user: current_user,
      school: @school,
      message: params[:message],
      status: "pending"
    )

    redirect_to airport_school_path(@school.airport.code, @school),
                notice: "Your claim request has been submitted and will be reviewed by our team."
  end

  private

  def set_airports
    @airports = Airport.order(:name)
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
