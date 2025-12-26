class Account < ApplicationRecord
  has_many :sessions
  has_many :images
  has_many :oauth_accounts
  belongs_to :icon, class_name: "Image", optional: true

  attribute :meta, :json, default: -> { {} }
  enum :visibility, { opened: 0, limited: 1, closed: 2 }
  enum :status, { normal: 0, locked: 1, deleted: 2 }
  attr_accessor :icon_aid

  before_validation :assign_icon
  before_create :set_aid

  validates :name,
            presence: true,
            length: { in: 1..50, allow_blank: true }
  validates :name_id,
            presence: true,
            length: { in: 5..50, allow_blank: true },
            format: { with: NAME_ID_REGEX, allow_blank: true },
            uniqueness: { case_sensitive: false, allow_blank: true }
  validates :description,
            allow_blank: true,
            length: { in: 1..500 }
  has_secure_password validations: false
  validates :password,
            allow_blank: true,
            length: { in: 8..30 },
            confirmation: true

  scope :is_normal, -> { where(status: :normal) }
  scope :isnt_deleted, -> { where.not(status: :deleted) }
  scope :is_opened, -> { where(visibility: :opened) }
  scope :isnt_closed, -> { where.not(visibility: :closed) }

  # === #

  def icon_file=(file)
    if file.present? && file.content_type.start_with?("image/")
      new_image = Image.new
      new_image.account = self
      new_image.image = file
      new_image.variant_type = "icon"
      self.icon = new_image
    end
  end

  def icon_url
    icon&.image_url || full_url("/static_assets/images/account-icon.webp")
  end

  def subscription_plan
    status = meta.dig("subscription", "subscription_status")
    return :basic unless %w[active trialing].include?(status)

    period_end = meta.dig("subscription", "current_period_end")&.to_time
    return :expired unless period_end && period_end > Time.current

    plan = meta.dig("subscription", "plan")
    plan&.to_sym || :unknown
  end

  def admin?
    meta["roles"]&.include?("admin")
  end

  private

  def assign_icon
    return if icon_aid.blank?

    self.icon = Image.find_by(
      account: self,
      aid: icon_aid
    )
  end
end
