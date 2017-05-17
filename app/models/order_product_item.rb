class OrderProductItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :order_product
  belongs_to :product
end
