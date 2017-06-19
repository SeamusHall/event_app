class User < ApplicationRecord
  acts_as_paranoid
  paginates_per 25
  include Gravtastic
  gravtastic size: 360

  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :orders

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable

  validates_presence_of :first_name, :last_name, :address, :city, :state, :country, :postal_code, :phone, on: [:update]

  # Email/phone/address verification
  validates_format_of :email, with: /@/
  validates :phone, phone: { possible: true, allow_blank: true, types: [:voip, :mobile], country_specifier: -> phone { phone.country.try(:upcase) } }, on: [:update]

  # TODO FIX THIS UP!!!
  geocoded_by :valid_address do |obj, results|
    if results.present?
      obj.latitude = results.first.latitude
      obj.longitude = results.first.longitude
    else
      obj.latitude = nil
      obj.longitude = nil
    end
  end

  before_validation :geocode, if: :address_changed?
  validate :found_address_presence, on: [:update]

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

  private

  def valid_address
    [city, state, postal_code, country, address].compact.join(', ')
  end

  def found_address_presence
    errors.add(:base, "Something went wrong. We couldn't find your address") if latitude.blank? || longitude.blank?
  end
end
