# require 'pandoc-ruby'
class Event < ApplicationRecord
  has_many :event_items

  validates_presence_of :name, :description, :page_body, :available_at, :unavailable_at, :starts_on, :ends_on

  accepts_nested_attributes_for :event_items, reject_if: proc { |attributes| attributes['description'].blank? }

  scope :available, ->(time=Time.now) { where("available_at <= :time AND unavailable_at >= :time", time: time) }

  def available?
    self.available_at <= Time.now and self.unavailable_at >= Time.now
  end

  def almost_over?
    self.available? and self.unavailable_at <= Time.now + 7.days
  end

  def dates
    self.starts_on.strftime('%m/%d/%Y') + ' - ' + self.ends_on.strftime('%m/%d/%Y')
  end

  # def converted_body
  #   @converter = PandocRuby.new(self.page_body, :from => :markdown, :to => :html)
  #   @converter.convert
  # end
end
