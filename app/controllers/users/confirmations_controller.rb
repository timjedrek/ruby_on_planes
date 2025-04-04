class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      respond_to do |format|
        format.html { redirect_to after_confirmation_path_for(resource_name, resource) }
        format.turbo_stream { redirect_to after_confirmation_path_for(resource_name, resource) }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def after_confirmation_path_for(resource_name, resource)
    if signed_in?(resource_name)
      root_path
    else
      new_session_path(resource_name)  # Redirect to sign-in
    end
  end
end