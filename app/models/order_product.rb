class OrderProduct < ActiveRecord::Base
  acts_as_paranoid
  paginates_per 9
  belongs_to :user

  has_many :order_product_items, dependent: :destroy
  accepts_nested_attributes_for :order_product_items, allow_destroy: true

  before_validation :calculate
  before_validation :update_finalized_on

  STATUSES = { 'pending' => 'Order Pending (pre-submit)',
               'progress' => 'Order In Progress (payment submitted)',
               'validated' => 'Order Validated (payment processed)',
               'archived' => 'Order Archived' }
  PENDING_STATUS = 'pending'
  PROGRESS_STATUS = 'progress'
  VALIDATED_STATUS = 'validated'
  ARCHIVED_STATUS = 'archived'

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

  def order_name
    self.user.first_name + ' ' + self.user.last_name
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

  def total_tax
    total_temp = 0
    self.order_product_items.each do |opi|
      total_temp += ( opi.product.price * opi.quantity )
    end
    return self.total - total_temp
  end

  def check_status
    self.status == OrderProduct::PROGRESS_STATUS || self.status == OrderProduct::VALIDATED_STATUS
  end

  private

  def calculate
    total_temp = 0
    self.order_product_items.each do |opi|
      total_temp += (opi.product.price * opi.quantity ) * (1.0 + opi.product.tax)
    end
    self.total = total_temp
  end

  def update_finalized_on
    if self.status == VALIDATED_STATUS
      self.finalized_on = Time.now unless self.finalized_on.present?
    else
      self.finalized_on = nil
    end
  end
end
