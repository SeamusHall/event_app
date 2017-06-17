module OrdersHelper
  def fetch_orders
    orders =  $redis.get("orders")
    if orders.nil?
      orders = Order.all.to_json
      $redis.set("orders", orders)
    end
    @orders = JSON.load orders
  end
end
