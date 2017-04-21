class User < ApplicationRecord
  acts_as_paranoid
  paginates_per 25
  include Gravtastic
  gravtastic

  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :orders

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable

  scope :active, ->() { where(locked_at: nil) }

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

end
