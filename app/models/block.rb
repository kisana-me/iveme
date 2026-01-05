require 'uri'

class Block < ApplicationRecord
  belongs_to :page
  belongs_to :image, optional: true

  attribute :meta, :json, default: -> { {} }
  enum :visibility, { opened: 0, limited: 1, closed: 2 }
  enum :status, { normal: 0, locked: 1, deleted: 2, specific: 3 }

  before_create :set_aid
  before_create :set_default_position

  validates :title,
    allow_blank: true,
    length: { in: 1..50 }
  validates :description,
    allow_blank: true,
    length: { in: 1..10_000 }
  validates :url,
    allow_blank: true,
    length: { in: 1..250 },
    format: {
      with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/,
      message: "は有効なURLではありません"
    }

  scope :ordered, -> { order(position: :asc) }
  scope :is_normal, -> { where(status: :normal) }
  scope :isnt_deleted, -> { where.not(status: :deleted) }
  scope :is_opened, -> { where(visibility: :opened) }
  scope :isnt_closed, -> { where.not(visibility: :closed) }

  # 上へ移動
  def move_higher
    # 同じプロフィールの、自分よりpositionが小さいブロックのうち、一番大きいもの（＝直上のやつ）を取得
    neighbor = page.blocks.where("position < ? AND position IS NOT NULL", position).order(position: :desc).first
    swap_position_with(neighbor) if neighbor
  end

  # 下へ移動
  def move_lower
    # 同じプロフィールの、自分よりpositionが大きいブロックのうち、一番小さいもの（＝直下のやつ）を取得
    neighbor = page.blocks.where("position > ? AND position IS NOT NULL", position).order(position: :asc).first
    swap_position_with(neighbor) if neighbor
  end

  private

  def swap_position_with(neighbor)
    return unless neighbor

    # トランザクションで安全に入れ替え
    Block.transaction do
      my_pos = self.position
      neighbor_pos = neighbor.position

      self.update!(position: neighbor_pos)
      neighbor.update!(position: my_pos)
    end
  end

  def set_default_position
    # 現在の最大値+1、なければ1
    max_pos = page.blocks.maximum(:position) || 0
    self.position = max_pos + 1
  end
end
