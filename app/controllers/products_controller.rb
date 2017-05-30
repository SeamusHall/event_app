class ProductsController < ApplicationController
  load_and_authorize_resource
  before_action :set_product, only: [:show]
  before_action :cart_initializer
  respond_to :html

  def index
    @products = Product.all.where(published: true)
  end

  def show
    respond_with(@product)
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

end
