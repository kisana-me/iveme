class Page < ApplicationRecord
  belongs_to :account
  has_many :blocks, dependent: :destroy
  belongs_to :icon, class_name: "Image", optional: true
  belongs_to :background, class_name: "Image", optional: true

  attribute :meta, :json, default: -> { {} }
  enum :visibility, { opened: 0, limited: 1, closed: 2 }
  enum :status, { normal: 0, locked: 1, deleted: 2, specific: 3 }
  attr_accessor :icon_aid, :background_aid

  before_validation :assign_images
  before_create :set_aid

  validates :name_id,
    presence: true,
    length: { in: 5..50, allow_blank: true },
    format: { with: NAME_ID_REGEX, message: :invalid_name_id_format, allow_blank: true },
    uniqueness: { case_sensitive: false, allow_blank: true }
  validates :title,
    presence: true,
    length: { in: 1..50, allow_blank: true }
  validates :description,
    presence: true,
    length: { in: 1..100_000, allow_blank: true }

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
    icon&.image_url || full_url("/static_assets/images/account-icon.webp")
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
