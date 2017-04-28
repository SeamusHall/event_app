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

  private
  def ensure_authorized
    raise CanCan::AccessDenied unless current_user.has_role?(:admin)
    @admin_page = true
  end
end
