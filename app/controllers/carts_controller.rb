class CartsController < ApplicationController
  before_action :authenticate_user!
  before_filter :cart_initializer

  def add
    @cart.add_item_to_cart(params[:id])
    session["cart"] = @cart.serialize # makes sure cart variable is a result of the serialization
                                      # overriding the session variable is a big no no
    product = Product.find(params[:id])
    redirect_to :back, notice: "Added #{product.name} to cart"
  end
  def show
  end
  def checkout
    @order_product = OrderProduct.new
  end
end
