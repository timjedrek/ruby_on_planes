class Admin::SchoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_school, only: [ :show, :edit, :update, :approve, :unapprove, :add_owner, :remove_owner ]

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

  private

  def set_school
    @school = School.find(params[:id])
  end

  def school_params
    params.require(:school).permit(
      :name, :website, :phone, :description, :est_planes, :est_cfis, :date_established,
      :part_141, :part_61, :accelerated_programs, :examining_authority, :featured, :approved,
      training_types: []
    )
  end

  def ensure_admin
    unless current_user.admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
