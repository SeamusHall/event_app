module Admin
  class UsersController < AdminController
    load_and_authorize_resource
    before_action :set_user, only: [:edit,:show,:update]

    def index
      @users = User.active.order(:email).page params[:page]
    end

    def update
      @user.del_cache
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
      else
        render "show"
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :phone, :address, :city, :state, :country, :postal_code, role_ids: [])
    end
  end
end
