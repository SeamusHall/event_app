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
      @order_product.send_message = false # Just in case people want a refund
      if @order_product.save
        respond_to do |format|
          format.html { redirect_to admin_orders_path, notice: 'Order was successfully validated.' }
        end
      end
    end

    def send_email_and_update_totals
      if @order_product.status == Order::DECLINED_STATUS
        @order_product.increment_product
        @order_product.send_message = true
        #OrderProductMailer.decline(@order_product).deliver_now
        @order_product.save
        redirect_to :back, notice: 'Stock has been updated.'
      elsif @order_product.status == Order::REFUNED_STATUS
        @order_product.increment_product
        @order_product.send_message = true
        #OrderProductMailer.refund(@order_product).deliver_now
        @order_product.save
        redirect_to :back, notice: 'Stock has been updated.'
      else
        flash[:error] = 'Something has gone terribly wrong. Please Contact IT for support.'
        redirect_to :back
      end
    end

    private
    def order_product_params
      permitted_params = []
      permitted_params << :status if current_user.has_role?(:admin)
      params.require(:order_product).permit(permitted_params)
    end

    def set_order_product
      @order_product = OrderProduct.find(params[:id])
    end

  end
end
