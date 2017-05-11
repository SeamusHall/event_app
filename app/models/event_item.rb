class EventItem < ApplicationRecord
  acts_as_paranoid
  belongs_to :event

  validates_presence_of :description, :price, :max_event, :max_order
  validates :price, numericality: { greater_than: 0 }
  validates :tax, numericality: { less_than: 0.99 }
  validates :min_freq, :max_event, :max_order, numericality: { only_integer: true , greater_than: 0 }
  #validate :valid_min_freq

  private
  def valid_min_freq
    errors.add(:min_freq, 'needs to be less than Check-In Date to end date') if self.min_freq >= (self.event.ends_on - self.event.starts_on) / 1.day
  end
end
