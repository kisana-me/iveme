class Block < ApplicationRecord
  belongs_to :page
  belongs_to :image, optional: true

  attribute :meta, :json, default: -> { {} }
  enum :visibility, { opened: 0, limited: 1, closed: 2 }
  enum :status, { normal: 0, locked: 1, deleted: 2, specific: 3 }

  before_create :set_aid

  validates :title,
    allow_blank: true,
    length: { in: 1..50 }
  validates :description,
    allow_blank: true,
    length: { in: 1..10_000 }
  validates :url,
    allow_blank: true,
    length: { in: 1..250 }

  scope :is_normal, -> { where(status: :normal) }
  scope :isnt_deleted, -> { where.not(status: :deleted) }
  scope :is_opened, -> { where(visibility: :opened) }
  scope :isnt_closed, -> { where.not(visibility: :closed) }
end
