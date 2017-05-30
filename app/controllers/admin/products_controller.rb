module Admin
  class ProductsController < AdminController
    load_and_authorize_resource
    before_action :set_product, only: [:show, :edit, :update, :publish, :unpublish]
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
        redirect_to admin_product_path(@product), notice: 'Product was successfully added.'
      else
        render "new"
      end
    end

    def update
      if @product.update(product_params)
        #set_background_job
        redirect_to admin_product_path(@product), notice: 'Product was successfully updated.'
      else
        render "edit"
      end
    end

    def publish
      @product.published = true
      if @product.save
        redirect_to :back, notice: 'Products was successfully published'
      else
        redirect_to :back, notice: 'Product was not published. Try again :{'
      end
    end

    def unpublish
      @product.published = false
      if @product.save
        redirect_to :back, notice: 'Products was successfully unpublished'
      else
        redirect_to :back, notice: 'Product was not unpublished. Try again :{'
      end
    end

    private
    def set_product
      @product = Product.find(params[:id])
    end

    def set_background_job
      count = 0
      @product.attachments.each do |attach|
        if attach.content_type.include? 'video'
          ProductWorker.perform_async(@product.id, count)
        end
        count += 1
      end
    end

    def product_params
      params.require(:product).permit(:name, :price, :description, :published, :status, :check_status, :page_body, :max_to_sell, :quantity, :tax, {attachments: []})
    end
  end
end
