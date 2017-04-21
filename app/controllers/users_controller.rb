class UsersController < ApplicationController
  before_action :ensure_authorization
  load_and_authorize_resource

  def index
    @roles = Role.all
    @users = User.order(:email).page params[:page]
  end

  def update
    @user.update(user_params)
    respond_with @user, location: -> { users_path }
  end

  private
  def ensure_authorization
    raise CanCan::AccessDenied unless current_user.has_role?(:admin)
  end
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :remember_me, role_ids: [])
  end
end
