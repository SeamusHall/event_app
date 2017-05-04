class Product < ApplicationRecord
  mount_uploader :image, ImageUploader

  validates_presence_of :name, :price, :description, :image
  validates :price, numericality: { greater_than: 0 }

  belongs_to :order_product

end
