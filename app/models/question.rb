class Question < ApplicationRecord
  belongs_to :page
  belongs_to :account, optional: true

  attribute :meta, :json, default: -> { {} }
  enum :status, { normal: 0, locked: 1, deleted: 2 }

  before_create :set_aid

  validates :content,
            presence: true,
            length: { in: 1..1000, allow_blank: true }
  validates :answer,
            allow_blank: true,
            length: { in: 1..1000 }

  scope :from_normal_accounts, -> { joins(:account).where(accounts: { status: :normal }) }
  scope :from_not_deleted_accounts, -> { joins(:account).where.not(accounts: { status: :deleted }) }
  scope :is_normal, -> { where(status: :normal) }
  scope :isnt_deleted, -> { where.not(status: :deleted) }
end
