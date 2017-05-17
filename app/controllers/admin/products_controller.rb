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
      if @product.save
        #set_background_job
        redirect_to admin_product_path(@product), notice: 'Product was successfully added to the working queue.'
      else
        render "new"
      end
    end

    def update
      if @product.update(product_params)
        #set_background_job
        redirect_to admin_product_path(@product), notice: 'Product was successfully added to the working queue.'
      else
        render "edit"
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_product_path(@product), notice: 'Product was successfully destroyed.'
    end

    private
    def set_product
      @product = Product.find(params[:id])
    end

    def set_background_job
      @product.attachments.each do |attach|
        if attach.content_type.include? 'video'
          ProductWorker.perform_async
        end
      end
    end

    def product_params
      params.require(:product).permit(:name, :price, :description, :published, :status, :check_status, :page_body, {attachments: []})
    end
  end
end
