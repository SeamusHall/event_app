class CartsController < ApplicationController
  before_filter :cart_initializer
  skip_before_filter :verify_authenticity_token

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
    load_cart_to_order_product_items
  end

  # automatically update users role to regular user
  # so that user can edit there information in order to
  # make payments
  def auto_update_role
    @user = current_user
    unless @user.roles.any?
      @user.role_ids = [2]
      @user.save
    end
    redirect_to edit_user_path(@user)
  end

  private

  def load_cart_to_order_product_items
    @cart.items.each do |item|
      @order_product.order_product_items.build(product: item.product, quantity: item.quantity)
    end
  end
end
