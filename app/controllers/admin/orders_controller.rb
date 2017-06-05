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

    def validate
      @order.status = Order::VALIDATED_STATUS
      if @order.save
        respond_to do |format|
          format.html { redirect_to admin_orders_path, notice: 'Order was successfully validated.' }
        end
      end
    end

    def show_orders_valid
      @orders = Order.all.where(status: Order::VALIDATED_STATUS).page params[:page]
      @order_products = OrderProduct.all.where(status: OrderProduct::VALIDATED_STATUS).page params[:page]
    end

    def show_orders_progress
      @orders = Order.all.where(status: Order::PROGRESS_STATUS).page params[:page]
      @order_products = OrderProduct.all.where(status: OrderProduct::PROGRESS_STATUS).page params[:page]
    end

    def show_orders_pending
      @orders = Order.all.where(status: Order::PENDING_STATUS).page params[:page]
      @order_products = OrderProduct.all.where(status: OrderProduct::PENDING_STATUS).page params[:page]
    end

    def show_orders_archived
      @orders = Order.all.where(status: Order::ARCHIVED_STATUS).page params[:page]
      @order_products = OrderProduct.all.where(status: OrderProduct::ARCHIVED_STATUS).page params[:page]
    end

    def show_orders_declined
      @orders = Order.all.where(status: Order::DECLINED_STATUS).page params[:page]
      @order_products = OrderProduct.all.where(status: OrderProduct::DECLINED_STATUS).page params[:page]
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
