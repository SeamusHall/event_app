include AuthorizeNet::API
module Admin
  class OrdersController < AdminController
    load_and_authorize_resource
    before_action :set_order, only: [:edit,:show,:update]

    def index
      @orders = Order.all.page params[:page]
      @order_products = OrderProduct.all.page params[:page]

      # For SpreadSheet
      @orders_all = Order.all + OrderProduct.all
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def update
      if @order.update(order_params)
        respond_with @order, location: -> { ["admin", @order] }
      else
        render "edit"
      end
    end

    def validate
      @order.status = Order::VALIDATED_STATUS
      @order.send_message = false # Just in case people want a refund
      if @order.save
        respond_to do |format|
          format.html { redirect_to admin_orders_path, notice: 'Order was successfully validated.' }
        end
      end
    end

    def send_email_and_update_totals
      if @order.status == Order::DECLINED_STATUS
        @order.increment_max_order
        @order.send_message = true
        #OrderMailer.decline(@order).deliver_now
        @order.save
        redirect_to :back, notice: 'Stock has been updated.'
      elsif @order.status == Order::REFUNED_STATUS
        @order.increment_max_order
        @order.send_message = true
        #OrderMailer.refund(@order).deliver_now
        @order.save
        redirect_to :back, notice: 'Stock has been updated.'
      else
        flash[:error] = 'Something has gone terribly wrong. Please Contact IT for support.'
        redirect_to :back
      end
    end

    def show_orders_valid
      @orders = Order.where(status: Order::VALIDATED_STATUS).page params[:page]
      @order_products = OrderProduct.where(status: OrderProduct::VALIDATED_STATUS).page params[:page]

      # For SpreadSheet
      @orders_all = Order.where(status: Order::VALIDATED_STATUS) + OrderProduct.where(status: OrderProduct::VALIDATED_STATUS)
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def show_orders_progress
      @orders = Order.where(status: Order::PROGRESS_STATUS).page params[:page]
      @order_products = OrderProduct.where(status: OrderProduct::PROGRESS_STATUS).page params[:page]

      # For SpreadSheet
      @orders_all = Order.where(status: Order::PROGRESS_STATUS) + OrderProduct.where(status: OrderProduct::PROGRESS_STATUS)
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def show_orders_pending
      @orders = Order.where(status: Order::PENDING_STATUS).page params[:page]
      @order_products = OrderProduct.where(status: OrderProduct::PENDING_STATUS).page params[:page]

      # For SpreadSheet
      @orders_all = Order.where(status: Order::PENDING_STATUS) + OrderProduct.where(status: OrderProduct::PENDING_STATUS)
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def show_orders_canceled
      @orders = Order.where(status: Order::CANCELED_STATUS).page params[:page]
      @order_products = OrderProduct.where(status: OrderProduct::CANCELED_STATUS).page params[:page]

      # For SpreadSheet
      @orders_all = Order.where(status: Order::CANCELED_STATUS) + OrderProduct.where(status: OrderProduct::CANCELED_STATUS)
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def show_orders_declined
      @orders = Order.where(status: Order::DECLINED_STATUS).page params[:page]
      @order_products = OrderProduct.where(status: OrderProduct::DECLINED_STATUS).page params[:page]

      # For SpreadSheet
      @orders_all = Order.where(status: Order::DECLINED_STATUS) + OrderProduct.where(status: OrderProduct::DECLINED_STATUS)
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def show_orders_refunded
      @orders = Order.where(status: Order::REFUNED_STATUS).page params[:page]
      @order_products = OrderProduct.where(status: OrderProduct::REFUNED_STATUS).page params[:page]

      # For SpreadSheet
      @orders_all = Order.where(status: Order::REFUNED_STATUS) + OrderProduct.where(status: OrderProduct::REFUNED_STATUS)
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:status)
    end
  end
end
