class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_authorized
  layout 'admin'

  def index
    @users = User.all
    @events = Event.available
    @orders = Order.not_validated
  end

  def users
    @users = User.active.order(:email).page params[:page]
  end

  def roles
    @roles = Role.all
  end

  def events
    @events = Event.all
  end

  def orders
    @orders = Order.all.page params[:page]
  end

  private
  def ensure_authorized
    raise CanCan::AccessDenied unless current_user.has_role?(:admin)
    @admin_page = true
  end
end
