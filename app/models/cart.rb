class Cart
	attr_reader :items

	def total_price
		@items.inject(0) {|sum, item| sum + item.total_price }
	end

	def self.build_from_hash(hash)
		# search through each item in the cart items hash and create new mapping
		items = if hash["cart"] then # Check if there is a cart item in hash. Hash represents current session
			hash["cart"]["items"].map do |item_data|
				CartItem.new(item_data["product_id"], item_data["quantity"])
			end
		else
			[]
		end
		new items
	end

	def initialize(items = [])
		@items = items
	end

	def add_item_to_cart(product_id)
		item = @items.find { |item| item.product_id == product_id }
		if item
			item.increment
		else
			@items << CartItem.new(product_id)
		end
	end

	def delete_item_from_cart(product_id)
		item = @items.find { |item| item.product_id == product_id }
		if !item.nil?
			item.quantity != 0 ? item.decrement : @items.delete(item)
		end
	end

	def clear_cart
		@items.clear
	end

	def empty?
		@items.empty?
	end

	# Adds items in cart based on session hash
	def serialize
		items = @items.map do |item|
		{
			"product_id" => item.product_id,
			"quantity" => item.quantity
		}
		end
		{
			"items" => items
		}
	end
end
