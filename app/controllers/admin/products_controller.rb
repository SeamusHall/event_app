module Admin
  class ProductsController < AdminController
    load_and_authorize_resource
    before_action :set_product, only: [:show, :edit, :update, :destroy]
    respond_to :html

    def index
      @products = Product.all.page params[:page]
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      @product.save
      redirect_to admin_product_path(@product), notice: 'Product was successfully created.'
    end

    def update
      @product.update(product_params)
      redirect_to admin_product_path(@product), notice: 'Product was successfully updated.'
    end

    def destroy
      @product.destroy
      redirect_to admin_product_path(@product), notice: 'Product was successfully destroyed.'
    end

    private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :price, :image, :description)
    end
  end
end
