class CartsController < ApplicationController
  before_action :cart_initializer
  skip_before_action :verify_authenticity_token

  def add
    @cart.add_item_to_cart(params[:id])
    session["cart"] = @cart.serialize # makes sure cart variable is a result of the serialization
                                      # overriding the session variable is a big no no
    product = Product.find(params[:id])
    redirect_to :back, notice: "Added #{product.name} to cart"
  end

  def remove
    @cart.delete_item_from_cart(params[:id])
    session["cart"] = @cart.serialize
    product = Product.find(params[:id])
    redirect_to :back, notice: "Removed #{product.name} from cart"
  end

  def clear
    @cart.clear_cart
    session["cart"] = @cart.serialize
    redirect_to :back, notice: "Cart Has Been Cleared"
  end

  def show
    @order_product = OrderProduct.new
  end
end
