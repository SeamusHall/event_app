class UsersController < ApplicationController
  load_and_authorize_resource

  def update
    if @user.update(user_params)
      respond_with @user, location: -> { user_path(@user) }, notice: "User was successfully updated"
    else
      render "edit"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :phone, :address, :city, :state, :country, :postal_code, role_ids: [])
  end
end
