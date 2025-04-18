class Admin::SchoolsController < Admin::BaseController
  before_action :set_school, only: [ :show, :edit, :update, :approve, :unapprove, :add_owner, :remove_owner ]
  before_action :set_airport, only: [ :new, :create ]

  def index
    @schools = School.includes(:airport, :state, :city).order(created_at: :desc)

    if params[:filter] == "unapproved"
      @schools = @schools.where(approved: false)
    elsif params[:filter] == "approved"
      @schools = @schools.where(approved: true)
    end

    @filter = params[:filter]
  end

  def show
    @contact_people = @school.contact_people.order(:name)
    @owners = @school.users
  end

  def edit
  end

  def update
    if @school.update(school_params)
      redirect_to admin_school_path(@school), notice: "School was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    @school.update(approved: true)
    redirect_to admin_school_path(@school), notice: "School has been approved and is now public."
  end

  def unapprove
    @school.update(approved: false)
    redirect_to admin_school_path(@school), notice: "School has been unapproved and is now hidden from public view."
  end

  def add_owner
    user = User.find_by(email: params[:email])

    if user.nil?
      redirect_to admin_school_path(@school), alert: "User with email '#{params[:email]}' not found."
      return
    end

    if @school.users.include?(user)
      redirect_to admin_school_path(@school), alert: "User is already an owner of this school."
      return
    end

    @school.users << user
    redirect_to admin_school_path(@school), notice: "User has been added as an owner of this school."
  end

  def remove_owner
    user = User.find(params[:user_id])
    @school.users.delete(user)
    redirect_to admin_school_path(@school), notice: "User has been removed as an owner of this school."
  end

  def new
    @school = @airport.schools.new
    @school.contact_people.build
  end

  def create
    @school = @airport.schools.new(school_params)
    @school.approved = true # Auto-approve admin-created schools

    if @school.save
      redirect_to admin_school_path(@school), notice: "School was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_school
    @school = School.find_by_slug_or_id(params[:id])
  end

  def set_airport
    @airport = Airport.find_by(code: params[:airport_code].upcase)

    if @airport.nil?
      redirect_to admin_schools_path, alert: "Airport not found."
    end
  end

  def school_params
    params.require(:school).permit(
      :name, :website, :phone, :description, :est_planes, :est_cfis, :date_established,
      :part_141, :part_61, :accelerated_programs, :examining_authority, :featured, :approved,
      training_types: [],
      contact_people_attributes: [ :id, :name, :title, :phone, :email, :_destroy ]
    )
  end
end
