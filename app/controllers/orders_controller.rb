include AuthorizeNet::API
class OrdersController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!
  before_action :cart_initializer
  before_action :set_orders, only: [:index]
  before_action :set_products_for_order, only: [:show]
  respond_to :js, :json, :html

  def create
    @order.user = current_user
    @order.status = Order::PENDING_STATUS
    if @order.save
      respond_to do |format|
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.js { redirect_to @order, notice: 'Order was successfully created.' }
      end
    else
      respond_to do |format|
        format.json { render json: @order.errors, status: :unprocessable_entity }
        # For multiple browser support (this doesn't display there errors)
        format.html { redirect_to :back, flash[:error] = @order.errors }
      end
    end
  end

  def update
    @order.update(order_params)
    respond_with @order, location: -> { @order }
  end

  def purchase
    # Just in case!!!!
    if @order.event_item.max_event == 0
      flash[:error] = 'Event is sold out!!!'
      redirect_to :back
    end
  end

  def cancel
    @order.status = Order::CANCELED_STATUS
    redirect_to :back, notice: (@order.save) ? 'Order has been successfully canceled.' : 'Order was not canceled.'
  end

  def make_purchase
    # Used to allow multiple transation on the same order if order gets declined
    # lets 1000 transation tries
    @invoice_num = rand(1000) if @order.status == Order::DECLINED_STATUS

    # create transation and request with Authorize
    transaction = Transaction.new(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['api_transaction_key'], :gateway => :production)
    request = CreateTransactionRequest.new

    # set up transaction request information
    request.transactionRequest = TransactionRequestType.new
    request.transactionRequest.amount = @order.total
    request.transactionRequest.transactionType = TransactionTypeEnum::AuthCaptureTransaction
    request.transactionRequest.payment = PaymentType.new
    request.transactionRequest.payment.creditCard = CreditCardType.new(params[:cc_num], params[:exp_date], params[:ccv])

    invoice_num = @order.status == Order::DECLINED_STATUS ? @order.id.to_s + @invoice_num.to_s : @order.id.to_s

    # add order and line item information
    request.transactionRequest.order = OrderType.new(invoice_num, @order.event_item.event.name)
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
      tax_amount = (@order.event_item.price * @order.quantity) * (@order.event_item.tax)
      request.transactionRequest.tax = ExtendedAmountType.new(tax_amount.round(2), "State Tax", "")
    end

    # add billing address to request
    request.transactionRequest.billTo = CustomerAddressType.new
    request.transactionRequest.billTo.firstName = current_user.first_name
    request.transactionRequest.billTo.lastName = current_user.last_name
    request.transactionRequest.billTo.zip = params[:zip].to_s
    request.transactionRequest.billTo.address = current_user.address
    request.transactionRequest.billTo.city = current_user.city
    request.transactionRequest.billTo.state = current_user.state
    request.transactionRequest.billTo.country = current_user.country
    request.transactionRequest.billTo.phoneNumber = current_user.phone

    # add customer info for receipt
    request.transactionRequest.customer = CustomerDataType.new
    request.transactionRequest.customer.email = current_user.email
    request.transactionRequest.customer.id = current_user.id.to_s(16) # hexadecimal user.id

    # perform transation with request
    response = transaction.create_transaction(request)

    # parse response
    if response.messages.resultCode == MessageTypeEnum::Ok
      if check_payment(response) # check payment response code to see if anything cuased it to decline
        @order.status = Order::DECLINED_STATUS
        @order.save
        unless response.transactionResponse.errors.nil?
          flash[:error] = "Transaction Failed. \n Error Code: #{response.transactionResponse.errors.errors[0].errorCode} \n #{response.transactionResponse.errors.errors[0].errorText}"
        else
          flash[:error] = "Transaction Failed. \n Error Code : #{response.messages.messages[0].code} \n Error Message : #{response.messages.messages[0].text}"
        end
        redirect_to :back
      else
        # success
        @order.placed_at = Time.now
        @order.payment_details = response.to_yaml
        @order.auth_code = response.transactionResponse.authCode
        @order.transaction_id = response.transactionResponse.transId
        @order.status = Order::PROGRESS_STATUS
        @order.send_message = false # For if refunded
        if @order.save
          @order.decrement_max_order # This needs to be after save as it will cause save issues for the last order
          respond_to do |format|
            format.html { redirect_to @order, notice: "Order was successfully placed! Thank you for your order!" }
          end
        else
          respond_to do |format|
            format.html { redirect_to purchase_order_path(@order), error: 'Payment processed, but order was not updated. Call University Housing during regular business hours (618.453.2301).' }
          end
        end
      end
    else
      # failure
      unless response.transactionResponse.errors.nil?
        flash[:error] = "Transaction Failed. \n Error Code: #{response.transactionResponse.errors.errors[0].errorCode} \n #{response.transactionResponse.errors.errors[0].errorText}"
      else
        flash[:error] = "Transaction Failed. \n Error Code : #{response.messages.messages[0].code} \n Error Message : #{response.messages.messages[0].text}"
      end
      redirect_to :back
    end
  end

  private

  # for more info
  # https://support.authorize.net/authkb/index?page=content&id=A50
  def check_payment(response)
    ret = false
    resp = response.transactionResponse.responseCode
    res_codes = ['2', '3', '4', '27', '44', '45', '65', '250', '251', '254']
    res_codes.each { |rs| rs == resp ? ret = true : next }
    return ret
  end

  def order_params
    permitted_params = [:event_item_id, :quantity, :terms, :comments]
    permitted_params << :status if current_user.has_role?(:admin)
    params.require(:order).permit(permitted_params)
  end

  def set_orders
    # current user should only see the orders they placed
    @orders = Order.where(user_id: current_user.id).page params[:page]
    @order_products = OrderProduct.where(user_id: current_user.id).page params[:page]

    # Check whether the order status is in progress or validated
    # either way when it's either status display product
    @orders.each do |order|
      if order.status == Order::PROGRESS_STATUS || order.status == Order::VALIDATED_STATUS
        @products = Product.where(check_status: Order::PROGRESS_STATUS)
      end
    end
  end

  def set_products_for_order
    order = Order.find(params[:id])
    if order.status == Order::PROGRESS_STATUS || order.status == Order::VALIDATED_STATUS
      @products = Product.where(check_status: Order::PROGRESS_STATUS)
    end
  end
end
