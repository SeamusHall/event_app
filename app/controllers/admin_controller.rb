class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_authorized
  layout 'admin'

  def index
    @users = User.all
    @events = Event.available
    @products = Product.all
    @orders = Order.not_validated
    @order_products = OrderProduct.not_validated
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

  def products
    @products = Product.all
  end

  def order_products
    @order_products = OrderProduct.all.page params[:page]
  end

  private
  def ensure_authorized
    raise CanCan::AccessDenied unless current_user.has_role?(:admin)
    @admin_page = true
  end
end
