class OrderProduct < ActiveRecord::Base
  acts_as_paranoid
  paginates_per 25
  belongs_to :user
  has_many :order_product_items

  STATUSES = { 'pending' => 'Order Pending (pre-submit)',
               'progress' => 'Order In Progress (payment submitted)',
               'validated' => 'Order Validated (payment processed)',
               'archived' => 'Order Archived' }
  PENDING_STATUS = 'pending'
  PROGRESS_STATUS = 'progress'
  VALIDATED_STATUS = 'validated'
  ARCHIVED_STATUS = 'archived'

  validates :status, inclusion: { in: STATUSES.keys }, presence: true
  validates :total, :first_name, :last_name, presence: true
  validates :total, numericality: { greater_than: 0.0 }

  before_create :only_one_pending_order

  scope :pending, ->() { where(status: PENDING_STATUS) }
  scope :progress, ->() { where(status: PROGRESS_STATUS) }
  scope :not_validated, -> { where("status = ? or status = ?", PENDING_STATUS, PROGRESS_STATUS) }

  default_scope { order('created_at DESC') }

  def extended_status
    STATUSES[status]
  end

  private
  def only_one_pending_order
    errors.add(:base, 'only one pending order allowed, please wait until previous order is processed') if (self.user.orders.pending.to_a - [self]).any?
  end
end
