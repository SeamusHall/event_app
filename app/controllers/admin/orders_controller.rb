include AuthorizeNet::API
module Admin
  class OrdersController < AdminController
    load_and_authorize_resource
    before_action :set_order, only: [:edit,:show,:update]

    def index
      @orders = Order.all.page params[:page]
      @order_products = OrderProduct.all.page params[:page]
      @orders_all = @orders + @order_products
      # For SpreadSheet
      respond_to do |format|
        format.html
        format.xlsx
      end
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
        OrderMailer.decline(@order).deliver_now
        @order.save
        redirect_to :back, notice: 'Email was successfully sent and stock has been updated.'
      elsif @order.status == Order::REFUNED_STATUS
        @order.increment_max_order
        @order.send_message = true
        OrderMailer.refund(@order).deliver_now
        @order.save
        redirect_to :back, notice: 'Email was successfully sent and stock has been updated.'
      else
        flash[:error] = 'Something has gone terribly wrong. Please Contact IT for support.'
        redirect_to :back
      end
    end

    def show_orders_valid
      @orders = Order.all.where(status: Order::VALIDATED_STATUS).page params[:page]
      @order_products = OrderProduct.all.where(status: OrderProduct::VALIDATED_STATUS).page params[:page]
      @orders_all = @orders + @order_products
      # For SpreadSheet
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def show_orders_progress
      @orders = Order.all.where(status: Order::PROGRESS_STATUS).page params[:page]
      @order_products = OrderProduct.all.where(status: OrderProduct::PROGRESS_STATUS).page params[:page]
      @orders_all = @orders + @order_products
      # For SpreadSheet
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def show_orders_pending
      @orders = Order.all.where(status: Order::PENDING_STATUS).page params[:page]
      @order_products = OrderProduct.all.where(status: OrderProduct::PENDING_STATUS).page params[:page]
      @orders_all = @orders + @order_products
      # For SpreadSheet
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def show_orders_canceled
      @orders = Order.all.where(status: Order::CANCELED_STATUS).page params[:page]
      @order_products = OrderProduct.all.where(status: OrderProduct::CANCELED_STATUS).page params[:page]
      @orders_all = @orders + @order_products
      # For SpreadSheet
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def show_orders_declined
      @orders = Order.all.where(status: Order::DECLINED_STATUS).page params[:page]
      @order_products = OrderProduct.all.where(status: OrderProduct::DECLINED_STATUS).page params[:page]
      @orders_all = @orders + @order_products
      # For SpreadSheet
      respond_to do |format|
        format.html
        format.xlsx
      end
    end

    def show_orders_refunded
      @orders = Order.all.where(status: Order::REFUNED_STATUS).page params[:page]
      @order_products = OrderProduct.all.where(status: OrderProduct::REFUNED_STATUS).page params[:page]
      @orders_all = @orders + @order_products
      # For SpreadSheet
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
      permitted_params = []
      permitted_params << :status if current_user.has_role?(:admin)
      params.require(:order).permit(permitted_params)
    end
  end
end
