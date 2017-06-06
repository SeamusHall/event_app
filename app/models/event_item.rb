class EventItem < ApplicationRecord
  acts_as_paranoid
  belongs_to :event

  validates_presence_of :description, :price, :max_event, :max_order
  validates :price, numericality: { greater_than: 0 }
  validates :tax, numericality: { less_than: 0.99 }
  validates :max_order, numericality: { only_integer: true , greater_than: 0 }
  validates :max_event, numericality: { only_integer: true , greater_than: -1 }
end
