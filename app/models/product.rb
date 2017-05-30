class Product < ApplicationRecord
  acts_as_paranoid
  paginates_per 25

  serialize :attachments, Array # Mysql Doesn't like arrays, this allows arrays to be stored in sql
  mount_uploaders :attachments, AttachmentUploader

  validates_presence_of :name, :price, :tax, :description, :attachments, :status, :page_body, :max_to_sell, :quantity
  validates :price, numericality: { greater_than: 0 }
  validates :tax, numericality: { greater_than: -1 }
  validates :quantity, numericality: { greater_than: -1 }

  belongs_to :order_product

  STATUSES = { 'In Stock' => 'Product In Stock',
               'Out Of Stock' => 'Product Out Of Stock'
             }

  IN_STOCK_STATUS = 'In Stock'
  OUT_OF_STOCK_STATUS = 'Out Of Stock'

  validates :status, inclusion: { in: STATUSES.keys }, presence: true

  def set_success(format, opts)
    self.success = true
  end

end
