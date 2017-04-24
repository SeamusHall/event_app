include AuthorizeNet::API
class OrderProductsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :cart_initializer
  before_action :build_order_items, only: [:show,:edit,:create,:update,:destroy]
  respond_to :js, :json

  def index
    @order_products = OrderProduct.accessible_by(current_ability).page params[:page]
  end

  def create
    @order_product = OrderProduct.create(order_product_params)
    @order_product.user = current_user
    @order_product.status = Order::PENDING_STATUS

    if @order_product.save
      @cart.items.each do |item|
        @item = OrderProductItem.new
        @item.order_product_id = @order_product.id
        @item.product_id = item.product.id
        @item.quantity = item.quantity
        @item.save
      end
      redirect_to @order_product, notice: "Order was created"
    else
      render "carts/checkout"
    end

  end

  def show
    @order_product = OrderProduct.find(params[:id])
  end

  def edit
    @order_product = OrderProduct.find(params[:id])
  end

  def update
    @order_product.update(order_product_params)
    respond_with @order_product, location: -> { @order_product }
  end

  def destroy
    @order_product.destroy
    respond_to do |format|
      format.html { redirect_to order_products_url, notice: 'Order was successfully destroyed.' }
    end
  end

  def make_purchase
    # create transation and request with Authorize
    transaction = Transaction.new(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['api_transaction_key'], :gateway => :sandbox)
    # transaction = Transaction.new('API_LOGIN', 'API_KEY', :gateway => :sandbox)
    request = CreateTransactionRequest.new

    # set up transaction request information
    request.transactionRequest = TransactionRequestType.new
    request.transactionRequest.amount = @order_product.total
    request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
    request.transactionRequest.payment = PaymentType.new
    request.transactionRequest.payment.creditCard = CreditCardType.new(params[:cc_num], params[:exp_date], params[:ccv])

    # add order and line item information
    request.transactionRequest.order = OrderType.new(@order_product.id.to_s, @order_product.order_item.product.name)
    request.transactionRequest.lineItems = LineItems.new([LineItemType.new(
        @order_product.order_item.id.to_s(16), # itemId
        @order_product.order_item.product.name, # name
        @order_product.order_item.product.description, # description
        @order_product.quantity, # quantity
        @order_product.event_item.price, # unitPrice
      )])

    # add billing address to request
    request.transactionRequest.billTo = CustomerAddressType.new
    request.transactionRequest.billTo.firstName = @order_product.first_name
    request.transactionRequest.billTo.lastName = @order_product.last_name
    request.transactionRequest.billTo.zip = params[:zip].to_s

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
      if @order_product.save
        respond_to do |format|
          format.html { redirect_to @order_product, notice: 'Order was successfully placed! Thank you for your order!' }
        end
      else
        respond_to do |format|
          format.html { redirect_to purcahse_order_product_path(@order_product), error: 'Payment processed, but order was not updated. Call University Housing during regular business hours (618.453.2301).' }
        end
      end
    else
      # failure
      respond_to do |format|
        format.html { redirect_to purcahse_order_product_path(@order_product), alert: "#{response.messages.messages[0].text} Error Code: #{response.transactionResponse.errors.errors[0].errorCode} (#{response.transactionResponse.errors.errors[0].errorText})" }
      end
    end

  end

  def validate
    @order_product.status = OrderProduct::VALIDATED_STATUS
    if @order_product.save
      respond_to do |format|
        format.html { redirect_to admin_path(action: 'order_products'), notice: 'Order was successfully validated.' }
      end
    end
  end

  private
  def order_product_params
    params.require(:order_product).permit(:user_id, :first_name, :last_name,:total, :payment_details,
                                          order_product_item_attributes: [:id,:product_id,:quantity])
  end

  def build_order_items
    @cart.items.each do |item|
      @order_product.order_product_items.build
    end
  end
end
