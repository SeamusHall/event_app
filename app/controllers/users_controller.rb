class UsersController < ApplicationController
  load_and_authorize_resource

  def update
    @user.del_cache
    if @user.update(user_params)
      respond_with @user, location: -> { user_path(@user) }, notice: "User was successfully updated"
    else
      render "show"
    end
  end

  def destroy
    # Completely delete user and anything related to that user
    orders = Order.where(user_id: @user.id) + OrderProduct.where(user_id: @user.id)
    orders.each { |o| o.really_destroy! }
    redirect_to root_path, notice: (@user.really_destroy!) ? "User was successfully removed" : "#{@user.full_name} was not successfully removed"
  end

  private
    # Important Don't Permit Role Ids here
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :phone, :address, :city, :state, :country, :postal_code)
    end
end
