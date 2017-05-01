module Admin
  class UsersController < AdminController
    load_and_authorize_resource
    before_action :set_user, only: [:edit,:show,:update]
    def index
      @roles = Role.all
      @users = User.active.order(:email).page params[:page]
    end

    def update
      @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :remember_me, role_ids: [])
    end
  end
end
