class Users::ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      redirect_to account_confirmed_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end