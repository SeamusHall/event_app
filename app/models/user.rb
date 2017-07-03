class User < ApplicationRecord
  acts_as_paranoid
  paginates_per 25
  include Gravtastic
  gravtastic size: 360

  after_save :reload_cache

  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :orders

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable

  validates_presence_of :first_name, :last_name, :address, :city, :state, :country, :postal_code, :phone, on: [:update]

  # Email/phone/address verification
  validates_format_of :email, with: /@/
  validates :phone, phone: { possible: true, allow_blank: true, types: [:voip, :mobile], country_specifier: -> phone { phone.country.try(:upcase) } }, on: [:update]

  # TODO FIX THIS UP!!!
  # geocoded_by :valid_address do |obj, results|
  #   if results.present?
  #     obj.latitude = results.first.latitude
  #     obj.longitude = results.first.longitude
  #   else
  #     obj.latitude = nil
  #     obj.longitude = nil
  #   end
  # end

  # before_validation :geocode, if: :address_changed?
  # validate :found_address_presence, on: [:update]

  scope :active, ->() { where(locked_at: nil) }

  # used to make sure user needs to fill out
  # their information. Find in carts/show events/show
  def check_nullity?
    first_name.nil? || last_name.nil? || phone.nil? || address.nil? || city.nil? || state.nil? || country.nil? || postal_code.nil?
  end

  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end

  def add_role(role_sym)
    role = Role.where(name: role_sym.to_s).first
    self.roles << role unless self.roles.include?(role)
  end

  def remove_role(role_sym)
    assignment = self.user_roles.joins(:role).where("roles.name = :name", name: role_sym.to_s)
    if assignment.any?
      self.user_roles.delete(assignment)
    end
  end

  def full_name
    self.first_name + ' ' + self.last_name unless self.first_name.nil? || self.last_name.nil?
  end

  def phone_to_int
    self.phone.to_i
  end

  # Delete user database columns into redis cache
  # Can't use before_save
  def del_cache
    1.upto(self.email.length)       { |n| $redis.zrem(self.email[0, n],                   "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
    unless check_nullity?
      1.upto(self.full_name.length)   { |n| $redis.zrem(self.full_name[0, n].to_s.downcase, "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
      1.upto(self.phone.length)       { |n| $redis.zrem(self.phone[0, n].to_s,              "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
      1.upto(self.first_name.length)  { |n| $redis.zrem(self.first_name[0, n].downcase,     "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
      1.upto(self.last_name.length)   { |n| $redis.zrem(self.last_name[0, n].downcase,      "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
      1.upto(self.city.length)        { |n| $redis.zrem(self.city[0, n].downcase,           "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
      1.upto(self.postal_code.length) { |n| $redis.zrem(self.postal_code[0, n].to_s,        "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
      1.upto(self.state.length)       { |n| $redis.zrem(self.state[0, n].to_s.downcase,     "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
      1.upto(self.country.length)     { |n| $redis.zrem(self.country[0, n].to_s.downcase,   "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
    end
  end

  private

    def valid_address
      [city, state, postal_code, country, address].compact.join(', ')
    end

    def found_address_presence
      errors.add(:base, "Something went wrong. We couldn't find your address") if latitude.blank? || longitude.blank?
    end

    # Load user database colums into redis cache
    def reload_cache
      1.upto(self.email.length)       { |n| $redis.zadd(self.email[0, n], n,                    "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
      unless check_nullity?
        1.upto(self.full_name.length)   { |n| $redis.zadd(self.full_name[0, n].to_s.downcase, n,  "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
        1.upto(self.phone.length)       { |n| $redis.zadd(self.phone[0, n].to_s, n,               "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
        1.upto(self.first_name.length)  { |n| $redis.zadd(self.first_name[0, n].downcase, n,      "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
        1.upto(self.last_name.length)   { |n| $redis.zadd(self.last_name[0, n].downcase, n,       "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
        1.upto(self.city.length)        { |n| $redis.zadd(self.city[0, n].downcase, n,            "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
        1.upto(self.postal_code.length) { |n| $redis.zadd(self.postal_code[0, n].to_s, n,         "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
        1.upto(self.state.length)       { |n| $redis.zadd(self.state[0, n].to_s.downcase, n,      "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
        1.upto(self.country.length)     { |n| $redis.zadd(self.country[0, n].to_s.downcase, n,    "#{self.id},#{self.full_name},#{self.phone},#{self.email},#{self.gravatar_url}") }
      end
    end
end
