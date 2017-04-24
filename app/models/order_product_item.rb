class OrderProductItem < ActiveRecord::Base
  belongs_to :order_product
  belongs_to :product
end
