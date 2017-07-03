class OrderProductItem < ApplicationRecord
  acts_as_paranoid

  belongs_to :order_product
  belongs_to :product

  validate :do_checks

  private
  def do_checks
    errors.add(:max_to_sell, "your quantity amount for #{product.name} must be less than or equal to #{product.max_to_sell} (Amount allowed per purchase)") if product.max_to_sell < quantity
    errors.add(:quantity, "#{product.name} is currently out of stock") if product.quantity == 0
    errors.add(:quantity, "You currently want more for #{product.name} then what we have") if product.quantity < quantity && product.quantity != 0
  end
end
