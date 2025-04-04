class Users::SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate(auth_options)
    if resource
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      redirect_to after_sign_in_path_for(resource)
    else
      self.resource = resource_class.new(sign_in_params)
      resource.errors.add(:base, "Invalid Email or Password")
      render :new, status: :unprocessable_entity  # Just HTML
    end
  end

  private

  def after_sign_in_path_for(resource)
    root_path
  end
end