class ProductsController < ApplicationController
  load_and_authorize_resource
  before_action :set_product, only: [:show]
  before_filter :cart_initializer
  respond_to :html

  def index
    @products = Product.all
    respond_with(@products)
  end

  def show
    respond_with(@product)
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :price, :image, :description)
    end
end
