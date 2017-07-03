module Admin
  class LayoutsController < AdminController
    def admin_navigation
      respond_to do |format|
        if params[:users]
          @users = User.redis_search(params[:users].downcase)
        end
        format.js
      end
    end

    def show_user_info
      @orders = Order.where(user_id: params[:id]).page params[:page]
      @order_products = OrderProduct.where(user_id: params[:id]).page params[:page]
      @user = User.find(params[:id])
    end
  end
end
