include AuthorizeNet::API
module Admin
  class OrderProductsController < AdminController
    load_and_authorize_resource
    before_action :set_order_product, only: [:show, :edit]
    respond_to :js, :json

    def index
      @order_products = OrderProduct.all.page params[:page]
    end

    def update
      if @order_product.update(order_product_params)
        redirect_to admin_order_product_path(@order_product), notice: 'Order was successfully updated.'
      else
        render "edit"
      end
    end

    def validate
      @order_product.status = OrderProduct::VALIDATED_STATUS
      if @order_product.save
        respond_to do |format|
          format.html { redirect_to admin_orders_path, notice: 'Order was successfully validated.' }
        end
      end
    end

    private
    def order_product_params
      permitted_params = [:user_id, :total, :payment_details]
      permitted_params << :status if current_user.has_role?(:admin)
      params.require(:order_product).permit(permitted_params)
    end

    def set_order_product
      @order_product = OrderProduct.find(params[:id])
    end

  end
end
