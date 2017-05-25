include AuthorizeNet::API
module Admin
  class OrdersController < AdminController
    load_and_authorize_resource
    before_action :set_order, only: [:edit,:show,:update]

    def index
      @orders = Order.all.page params[:page]
      @order_products = OrderProduct.all.page params[:page]
    end

    def update
      if @order.update(order_params)
        redirect_to admin_order_path(@order), notice: 'Order was successfully updated.'
      else
        render "edit"
      end
    end

    def destroy
      @order.destroy
      respond_to do |format|
        format.html { redirect_to admin_orders_path, notice: 'Order was successfully destroyed.' }
      end
    end

    def validate
      @order.status = Order::VALIDATED_STATUS
      if @order.save
        respond_to do |format|
          format.html { redirect_to admin_orders_path, notice: 'Order was successfully validated.' }
        end
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      permitted_params = [:event_item_id, :quantity, :start_date, :end_date, :first_name, :last_name]
      permitted_params << :status if current_user.has_role?(:admin)
      params.require(:order).permit(permitted_params)
    end
  end
end
