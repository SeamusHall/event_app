class Order < ApplicationRecord
  paginates_per 25
  belongs_to :user
  belongs_to :event_item

  STATUSES = { 'pending' => 'Order Pending (pre-submit)',
               'progress' => 'Order In Progress (payment submitted)',
               'validated' => 'Order Validated (payment processed)',
               'archived' => 'Order Archived' }
  PENDING_STATUS = 'pending'
  PROGRESS_STATUS = 'progress'
  VALIDATED_STATUS = 'validated'
  ARCHIVED_STATUS = 'archived'

  before_validation :perform_total_calculation
  before_validation :update_finalized_on

  validate :valid_dates
  validate :quantity_less_than_max_order

  validates :status, inclusion: { in: STATUSES.keys }, presence: true
  validates :quantity, :total, :start_date, :end_date, :first_name, :last_name, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :total, numericality: { greater_than: 0.0 }

  before_create :only_one_pending_order

  scope :pending, ->() { where(status: PENDING_STATUS) }
  scope :progress, ->() { where(status: PROGRESS_STATUS) }
  scope :not_validated, -> { where("status = ? or status = ?", PENDING_STATUS, PROGRESS_STATUS) }

  default_scope { order('created_at DESC') }

  def extended_status
    STATUSES[status]
  end

  def dates
    self.start_date.strftime('%m/%d/%Y') + ' - ' + self.end_date.strftime('%m/%d/%Y')
  end

  private
  def valid_dates
    if start_date and end_date
      errors.add(:start_date, 'must occur before end date') if start_date > end_date
      errors.add(:end_date, 'must occur after start date') if start_date == end_date
      errors.add(:start_date, 'must occur inside event dates') if start_date < self.event_item.event.starts_on or start_date > self.event_item.event.ends_on
      errors.add(:end_date, 'must occur inside event dates') if end_date < self.event_item.event.starts_on or end_date > self.event_item.event.ends_on
      errors.add(:base, 'minimum date freqency not met') if (end_date - start_date) + 1.day / 1.day < self.event_item.min_freq
    end
  end

  def only_one_pending_order
    errors.add(:base, 'only one pending order allowed, please wait until previous order is processed') if (self.user.orders.pending.to_a - [self]).any?
  end

  def quantity_less_than_max_order
    errors.add(:quantity, "must be less than order max (#{self.event_item.max_order})") if self.quantity and self.quantity > self.event_item.max_order
  end

  def perform_total_calculation
    if self.quantity and self.start_date and self.end_date and self.event_item and self.status == PENDING_STATUS
      qty = self.quantity
      freq = self.event_item.flat_rate ? 1.0 : (self.end_date - self.start_date + 1.day)/1.day
      self.total = (self.event_item.price * qty * freq) * (1.0 + self.event_item.tax)
    end
  end

  def update_finalized_on
    if self.status == VALIDATED_STATUS
      self.finalized_on = Time.now unless self.finalized_on.present?
    else
      self.finalized_on = nil
    end
  end
end
