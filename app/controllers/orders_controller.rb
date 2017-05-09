include AuthorizeNet::API
class OrdersController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  respond_to :js, :json

  def index
    @orders = Order.all.where(user_id: current_user.id).page params[:page] # current user should only see the orders they placed
  end

  def create
    # set controller params
    @order.user = current_user
    @order.status = Order::PENDING_STATUS
    if @order.save
      respond_to do |format|
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.js { redirect_to @order, notice: 'Order was successfully created.' }
      end
    else
      respond_to do |format|
        format.json { render json: @order.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    @order.update(order_params)
    respond_with @order, location: -> { @order }
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
    end
  end

  # new actions
  def purchase
  end

  def make_purchase
    # create transation and request with Authorize
    transaction = Transaction.new(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['api_transaction_key'], :gateway => :production)
    # transaction = Transaction.new('API_LOGIN', 'API_KEY', :gateway => :sandbox)
    request = CreateTransactionRequest.new

    # set up transaction request information
    request.transactionRequest = TransactionRequestType.new
    request.transactionRequest.amount = @order.total
    request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
    request.transactionRequest.payment = PaymentType.new
    request.transactionRequest.payment.creditCard = CreditCardType.new(params[:cc_num], params[:exp_date], params[:ccv])

    # add order and line item information
    request.transactionRequest.order = OrderType.new(@order.id.to_s, @order.event_item.event.name)
    request.transactionRequest.lineItems = LineItems.new([LineItemType.new(
        @order.event_item.id.to_s(16), # itemId
        @order.event_item.event.name, # name
        @order.event_item.description, # description
        @order.quantity, # quantity
        @order.event_item.price, # unitPrice
        (@order.event_item.tax > 0.0 ? "true" : "false") # taxable?
      )])

    # tax
    if @order.event_item.tax > 0.0
      qty = @order.quantity
      freq = @order.event_item.flat_rate ? 1.0 : (@order.end_date - @order.start_date + 1.day)/1.day
      tax_amount = (@order.event_item.price * qty * freq) * (@order.event_item.tax)
      request.transactionRequest.tax = ExtendedAmountType.new(tax_amount.round(2), "State Tax", "")
    end

    # add billing address to request
    request.transactionRequest.billTo = CustomerAddressType.new
    request.transactionRequest.billTo.firstName = @order.first_name
    request.transactionRequest.billTo.lastName = @order.last_name
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
      @order.placed_at = Time.now
      @order.status = Order::PROGRESS_STATUS
      @order.payment_details = response.to_yaml
      @order.auth_code = response.transactionResponse.authCode
      @order.transaction_id = response.transactionResponse.transId
      if @order.save
        respond_to do |format|
          format.html { redirect_to @order, notice: 'Order was successfully placed! Thank you for your order!' }
        end
      else
        respond_to do |format|
          format.html { redirect_to purchase_order_path(@order), error: 'Payment processed, but order was not updated. Call University Housing during regular business hours (618.453.2301).' }
        end
      end
    else
      # failure
      respond_to do |format|
        format.html { redirect_to purchase_order_path(@order), alert: "#{response.messages.messages[0].text} Error Code: #{response.transactionResponse.errors.errors[0].errorCode} (#{response.transactionResponse.errors.errors[0].errorText})" }
      end
    end

  end

  private
  def order_params
    permitted_params = [:event_item_id, :quantity, :start_date, :end_date, :first_name, :last_name]
    permitted_params << :status if current_user.has_role?(:admin)
    params.require(:order).permit(permitted_params)
  end
end
