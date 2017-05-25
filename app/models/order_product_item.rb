class OrderProductItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :order_product
  belongs_to :product

  validate :do_checks

  private
  def do_checks
    errors.add(:max_to_sell, 'Item quantity can not be more than quantity allowed to sell') if product.max_to_sell < quantity
    errors.add(:quantity, 'We are out of stock on product') if product.quantity == 0
    errors.add(:quantity, 'You currently want more than what we have') if product.quantity < quantity && product.quantity != 0
  end
end
