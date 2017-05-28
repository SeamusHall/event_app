include AuthorizeNet::API
class OrderProductsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :cart_initializer
  before_action :build_order_product_items, only: [:create]
  before_action :set_order_product, only: [:show, :edit]
  respond_to :js, :json

  def index
    @order_products = OrderProduct.all.where(user_id: current_user.id).page params[:page] # current user should only see the orders they placed
  end

  def create
    @order_product = OrderProduct.create(order_product_params)
    @order_product.user = current_user
    @order_product.status = Order::PENDING_STATUS

    if @order_product.save
      respond_to do |format|
        format.html { redirect_to @order_product, notice: 'Order was successfully created. Note that although created until you make a purchase it does not garentee that your item will be available.'}
        format.js { redirect_to @order_product, notice: 'Order was successfully created. Note that although created until you make a purchase it does not garentee that your item will be available.' }
      end
    else
      respond_to do |format|
        format.json { render json: @order_product.errors, status: :unprocessable_entity}
      end
    end
  end

  def show
    @cart.clear_cart
    session["cart"] = @cart.serialize
  end

  def update
    @order_product.update(order_product_params)
    respond_with @order_product, location: -> { @order_product }
  end

  def make_purchase
    # create transation and request with Authorize
    transaction = Transaction.new(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['api_transaction_key'], :gateway => :production)
    request = CreateTransactionRequest.new

    # set up transaction request information
    request.transactionRequest = TransactionRequestType.new
    request.transactionRequest.amount = @order_product.total
    request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
    request.transactionRequest.payment = PaymentType.new
    request.transactionRequest.payment.creditCard = CreditCardType.new(params[:cc_num], params[:exp_date], params[:ccv])


    # add billing address to request
    request.transactionRequest.billTo = CustomerAddressType.new
    request.transactionRequest.billTo.firstName = current_user.first_name
    request.transactionRequest.billTo.lastName = current_user.last_name
    request.transactionRequest.billTo.zip = params[:zip].to_s
    request.transactionRequest.billTo.address = current_user.address
    request.transactionRequest.billTo.city = current_user.city
    request.transactionRequest.billTo.state = current_user.state
    request.transactionRequest.billTo.country = current_user.country

    # add customer info for receipt
    request.transactionRequest.customer = CustomerDataType.new
    request.transactionRequest.customer.email = current_user.email
    request.transactionRequest.customer.id = current_user.id.to_s(16) # hexadecimal user.id

    # perform transation with request
    response = transaction.create_transaction(request)

    # parse response
    if response.messages.resultCode == MessageTypeEnum::Ok
      # success
      @order_product.placed_at = Time.now
      @order_product.status = OrderProduct::PROGRESS_STATUS
      @order_product.payment_details = response.to_yaml
      @order_product.auth_code = response.transactionResponse.authCode
      @order_product.transaction_id = response.transactionResponse.transId
      decrement_product(@order_product)
      if @order_product.save
        decrement_product(@order_product) # decrease amount of product have left if saved
        respond_to do |format|
          format.html { redirect_to @order_product, notice: 'Order was successfully placed! Thank you for your order!' }
        end
      else
        respond_to do |format|
          format.html { redirect_to purchase_order_product_path(@order_product), error: 'Payment processed, but order was not updated. Call University Housing during regular business hours (618.453.2301).' }
        end
      end
    else
      # failure
      respond_to do |format|
        format.html { redirect_to purchase_order_product_path(@order_product), alert: "#{response.messages.messages[0].text} Error Code: #{response.transactionResponse.errors.errors[0].errorCode} (#{response.transactionResponse.errors.errors[0].errorText})" }
      end
    end

  end

  private
  def order_product_params
    permitted_params = [:user_id, :total, :payment_details,
                        order_product_items_attributes: [:id,:product_id,:quantity]]
    permitted_params << :status if current_user.has_role?(:admin)
    params.require(:order_product).permit(permitted_params)
  end

  def set_order_product
    @order_product = OrderProduct.find(params[:id])
  end

  # Finds the product id of each order_product_item
  # Updates the amount left on product in database
  def decrement_product(order_product)
    order_product.order_product_items.each do |opi|
      product = Product.find(opi.product_id)
      product.quantity -= opi.quantity
      product.save
    end
  end

  def build_order_product_items
    @cart.items.each do |item|
      @order_product.order_product_items.build
    end
  end
end
