class Order < ApplicationRecord
  acts_as_paranoid
  paginates_per 9
  belongs_to :user
  belongs_to :event_item

  STATUSES = { 'pending'   => 'Order Pending (pre-submit)',
               'progress'  => 'Order In Progress (payment submitted)',
               'validated' => 'Order Validated (payment processed)',
               'canceled'  => 'Order Canceled',
               'declined'  => 'Card Declined',
               'refunded'  => 'Order Refunded' }
  PENDING_STATUS = 'pending'
  PROGRESS_STATUS = 'progress'
  VALIDATED_STATUS = 'validated'
  CANCELED_STATUS = 'canceled'
  DECLINED_STATUS = 'declined'
  REFUNED_STATUS = 'refunded'

  before_validation :perform_total_calculation
  before_validation :update_finalized_on

  validate :do_checks

  validates :status, inclusion: { in: STATUSES.keys }, presence: true
  validates :quantity, :total, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :total, numericality: { greater_than: 0.0 }

  scope :pending, ->() { where(status: PENDING_STATUS) }
  scope :progress, ->() { where(status: PROGRESS_STATUS) }
  scope :not_validated, -> { where("status = ? or status = ?", PENDING_STATUS, PROGRESS_STATUS) }

  default_scope { order('created_at DESC') }

  def extended_status
    STATUSES[status]
  end

  def check_status
    self.status == Order::PROGRESS_STATUS || self.status == Order::VALIDATED_STATUS || self.status == Order::CANCELED_STATUS || self.status == Order::REFUNED_STATUS
  end

  def cant_edit_status
    self.status == Order::CANCELED_STATUS || self.status == Order::REFUNED_STATUS
  end

  # Deletes the amount left in event_item so we know
  # how many we have left to sell (Based on quantity customer wants per order)
  def decrement_max_order
    self.event_item.max_event -= self.quantity
    self.event_item.save
  end

  def increment_max_order
    self.event_item.max_event += self.quantity
    self.event_item.save
  end

  private

  def do_checks
    errors.add(:terms, 'Must agree to terms and services') if !terms
    errors.add(:quantity, "must be less than order max (#{self.event_item.max_order})") if self.quantity and self.quantity > self.event_item.max_order
    errors.add(:quantity, "Event is sold out!") if self.event_item.max_event == 0
    errors.add(:quantity, "You currently want more for #{self.event_item.name} then what we have") if self.event_item.max_event < self.quantity && self.event_item.max_event != 0
  end

  def perform_total_calculation
    self.total = (self.event_item.price * self.quantity ) * (1.0 + self.event_item.tax)
  end

  def update_finalized_on
    if self.status == VALIDATED_STATUS
      self.finalized_on = Time.now unless self.finalized_on.present?
    else
      self.finalized_on = nil
    end
  end
end
