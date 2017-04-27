include AuthorizeNet::API
module Admin
  class OrderProductsController < AdminController
    before_action :set_order_product, only: [:show, :edit]
    respond_to :js, :json

    def index
      @order_products = OrderProduct.all.page params[:page]
    end

    def update
      @order_product.update(order_product_params)
      respond_with(@order_product)
    end

    def destroy
      @order_product.destroy
      respond_to do |format|
        format.html { redirect_to admin_order_products_path, notice: 'Order was successfully destroyed.' }
      end
    end

    def validate
      @order_product.status = OrderProduct::VALIDATED_STATUS
      if @order_product.save
        respond_to do |format|
          format.html { redirect_to admin_order_products_path, notice: 'Order was successfully validated.' }
        end
      end
    end

    private
    def order_product_params
      permitted_params = [:user_id, :first_name, :last_name, :total, :payment_details,
                           order_product_item_attributes: [:id,:product_id,:quantity]]
      permitted_params << :status if current_user.has_role?(:admin)
      params.require(:order_product).permit(permitted_params)
    end

    def set_order_product
      @order_product = OrderProduct.find(params[:id])
    end

    def build_order_product_items
      @cart.items.each do |item|
        @order_product.order_product_items.build
      end
    end
  end
end
