class ProductsController < ApplicationController
  load_and_authorize_resource
  before_action :set_product, only: [:show]
  before_action :cart_initializer
  respond_to :html

  def index
    @products = Product.all.where(published: true)
  end

  private

  def set_product
    # find all orders that belong to current_user unless current_user isn't signed in
    order =  Order.all.where(user_id: current_user.id) unless current_user.nil?

    if Product.find(params[:id]).published # if an order is published display product
      @product = Product.find(params[:id])
    elsif !order.nil?
      # check each order that belongs to a user and check if the status is in progress or validated
      if order.each { |o| Product.find(params[:id]).status == o.status || o.status == Order::VALIDATED_STATUS }
        @product = Product.find(params[:id])
      end
    else
      # Display error message
      flash[:error] = "You are not allowed to acess that page."
      redirect_to root_path
    end
  end

end
