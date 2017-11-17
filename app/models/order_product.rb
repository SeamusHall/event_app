class OrderProduct < ApplicationRecord
  acts_as_paranoid
  paginates_per 9
  belongs_to :user

  has_many :order_product_items, dependent: :destroy

  # Allows Order Items to be deleted from Orders
  accepts_nested_attributes_for :order_product_items, allow_destroy: true

  before_validation :update_finalized_on

  # Order Statuses for OrderProduct NOTE: Not actually needed could use the one from Order.rb
  STATUSES = { 'pending'   => 'Order Pending (pre-submit)',
               'progress'  => 'Order In Progress (payment submitted)',
               'validated' => 'Order Validated (payment processed)',
               'canceled'  => 'Order canceled',
               'declined'  => 'Card Declined',
               'refunded'  => 'Order Refunded' }
  PENDING_STATUS = 'pending'
  PROGRESS_STATUS = 'progress'
  VALIDATED_STATUS = 'validated'
  CANCELED_STATUS = 'canceled'
  DECLINED_STATUS = 'declined'
  REFUNED_STATUS = 'refunded'

  # TODO Method used to check if and order has at least one Item in it
  # validate :check_if_order_hase_one_item, on: [:update]

  validates :status, inclusion: { in: STATUSES.keys }, presence: true
  validates :total, presence: true
  validates :total, numericality: { greater_than: 0.0 }

  scope :pending, ->() { where(status: PENDING_STATUS) }
  scope :progress, ->() { where(status: PROGRESS_STATUS) }
  scope :not_validated, -> { where("status = ? or status = ?", PENDING_STATUS, PROGRESS_STATUS) }

  default_scope { order('created_at DESC') }

  def extended_status
    STATUSES[status]
  end

  # Finds the product id of each order_product_item
  # Updates the amount left on product in database
  def decrement_product
    self.order_product_items.each do |opi|
      product = Product.find(opi.product_id)
      product.quantity -= opi.quantity
      product.save
    end
  end

  # Finds the product id of each order_product_item
  # Updates the amount left on product in database
  def increment_product
    self.order_product_items.each do |opi|
      product = Product.find(opi.product_id)
      product.quantity += opi.quantity
      product.save
    end
  end

  # check to see if a product statifies (I spell good)
  # conditions
  def check_stock
    ret = false
    self.order_product_items.each do |opi|
      if opi.product.max_to_sell < opi.quantity || opi.product.quantity == 0 || ( opi.product.quantity < opi.quantity && opi.product.quantity != 0 )
        ret = true
      end
    end
    ret
  end

  # Calculates the total amount of tax
  # to send over to Authorize
  def total_tax
    total_temp = 0
    self.order_product_items.each do |opi|
      total_temp += ( opi.product.price * opi.quantity )
    end
    self.total - total_temp
  end

  def check_status
    self.status == OrderProduct::PROGRESS_STATUS || self.status == OrderProduct::VALIDATED_STATUS || self.status == OrderProduct::CANCELED_STATUS || self.status == OrderProduct::REFUNED_STATUS
  end

  # Calculates Total for order
  def calculate_total
    total_temp = 0
    self.order_product_items.each do |opi|
      total_temp += (opi.product.price * opi.quantity ) * (1.0 + opi.product.tax)
    end
    self.total = total_temp
  end

  private

    # Update date order was finalized_on
    def update_finalized_on
      self.finalized_on = (self.status == VALIDATED_STATUS && !self.finalized_on.present?) ? Time.now : nil
    end

    # TODO NOT MUCH MORE I CAN THINK OF
    # checks to make sure there is at least one item in the order
    def check_if_order_hase_one_item
      errors.add(:base, "Your order must have at least one item") unless self.order_product_items.only_deleted.empty?
    end
end
