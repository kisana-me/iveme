class Page < ApplicationRecord
  belongs_to :account
  has_many :blocks, dependent: :destroy
  belongs_to :icon, class_name: "Image", optional: true
  belongs_to :background, class_name: "Image", optional: true

  HTML_COLOR_REGEX = /\A#(?:\h{3}|\h{6})\z/i

  attribute :meta, :json, default: -> { {} }
  enum :visibility, { opened: 0, limited: 1, closed: 2 }
  enum :status, { normal: 0, locked: 1, deleted: 2, specific: 3 }
  attr_accessor :icon_aid, :background_aid, :remove_icon, :remove_background

  before_validation :normalize_theme_colors
  before_validation :assign_images
  before_create :set_aid

  validate :validate_subscription_page_limit, on: :create

  validates :name_id,
    presence: true,
    length: { in: 1..20, allow_blank: true },
    format: { with: NAME_ID_REGEX, message: :invalid_name_id_format, allow_blank: true },
    uniqueness: { scope: :account_id, case_sensitive: false, allow_blank: true }
  validates :title,
    presence: true,
    length: { in: 1..50, allow_blank: true }
  validates :description,
    presence: true,
    length: { in: 1..100_000, allow_blank: true }

  validates :font_color,
    format: { with: HTML_COLOR_REGEX, message: "は#FFFFFF形式で入力してください" },
    allow_nil: true
  validates :block_color,
    format: { with: HTML_COLOR_REGEX, message: "は#FFFFFF形式で入力してください" },
    allow_nil: true
  validates :accent_color,
    format: { with: HTML_COLOR_REGEX, message: "は#FFFFFF形式で入力してください" },
    allow_nil: true
  validates :background_color,
    format: { with: HTML_COLOR_REGEX, message: "は#FFFFFF形式で入力してください" },
    allow_nil: true
  validates :gradient_color,
    format: { with: HTML_COLOR_REGEX, message: "は#FFFFFF形式で入力してください" },
    allow_nil: true

  scope :is_normal, -> { where(status: :normal) }
  scope :isnt_deleted, -> { where.not(status: :deleted) }
  scope :is_opened, -> { where(visibility: :opened) }
  scope :isnt_closed, -> { where.not(visibility: :closed) }

  def icon_file=(file)
    if file.present? && file.content_type.start_with?("image/")
      new_image = Image.new
      new_image.account = account
      new_image.image = file
      new_image.variant_type = "icon"
      self.icon = new_image
    end
  end

  def icon_url
    icon&.image_url || full_url("/static_assets/images/icon.png")
  end

  def background_file=(file)
    if file.present? && file.content_type.start_with?("image/")
      new_image = Image.new
      new_image.account = account
      new_image.image = file
      new_image.variant_type = "normal"
      self.background = new_image
    end
  end

  def background_url
    background&.image_url || full_url("/static_assets/images/noimage.webp")
  end

  private

  def normalize_theme_colors
    %i[
      font_color
      block_color
      accent_color
      background_color
      gradient_color
    ].each do |attr|
      value = self[attr]
      value = value.strip if value.respond_to?(:strip)
      value = nil if value.blank?
      value = value.upcase if value.present?
      self[attr] = value
    end
  end

  def validate_subscription_page_limit
    return if account.blank?

    limit = subscription_page_limit
    current_count = account.pages.isnt_deleted.count
    return if current_count < limit

    errors.add(:base, :page_limit_exceeded, limit: limit)
  end

  def subscription_page_limit
    case account.subscription_plan
    when :plus
      2
    when :premium
      5
    when :luxury
      8
    else
      1
    end
  end

  def assign_images
    if icon_aid.present?
      self.icon = Image.is_normal.find_by(
        aid: icon_aid
      )
    end
    if background_aid.present?
      self.background = Image.is_normal.find_by(
        aid: background_aid
      )
    end
  end
end
