class TravelGuide < ApplicationRecord
  has_one_attached :image
  has_many_attached :body_images

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug
  before_validation :set_default_published_at, if: -> { active? && published_at.blank? }

  scope :published, -> { where(active: true).where("published_at IS NOT NULL AND published_at <= ?", Time.current) }
  scope :draft, -> { where("active IS NOT TRUE OR published_at IS NULL OR published_at > ?", Time.current) }
  scope :active, -> { published }

  ALLOWED_TAGS = %w[p h2 h3 strong b em i u s blockquote ul ol li a img figure figcaption hr br].freeze
  ALLOWED_ATTRIBUTES = %w[href src alt title target rel class loading].freeze

  def to_param
    slug
  end

  def published?
    active? && published_at.present? && published_at <= Time.current
  end

  def draft?
    !published?
  end

  def status
    published? ? "published" : "draft"
  end

  def publish!
    update!(active: true, published_at: published_at.presence || Time.current)
  end

  def unpublish!
    update!(active: false)
  end

  def tags
    self[:tags].to_a
  end

  def tag_list
    self[:tags].to_a.join(", ")
  end

  def tag_list=(value)
    self[:tags] = Array(value).flat_map { |v| v.to_s.split(",") }.map(&:strip).reject(&:blank?).uniq
  end

  def meta_description_or_fallback
    meta_description.presence || excerpt.presence || title
  end

  def estimated_reading_time
    words = content.to_s.split.size
    [ (words / 200.0).ceil, 1 ].max
  end

  def sanitized_content
    return "" if content.blank?

    raw_html = content.include?("<") ? content : ActionController::Base.helpers.simple_format(content)
    pruned = Loofah.fragment(raw_html).scrub!(:prune).to_s
    ActionController::Base.helpers.sanitize(
      pruned,
      tags: ALLOWED_TAGS,
      attributes: ALLOWED_ATTRIBUTES
    )
  end

  private

  def set_default_published_at
    self.published_at = Time.current
  end

  def generate_slug
    if slug.blank? && title.present?
      base_slug = title.parameterize.presence || "guide-#{SecureRandom.hex(4)}"
      base_slug = base_slug.truncate(100, omission: "")
      new_slug = base_slug
      counter = 1
      while TravelGuide.where.not(id: id).exists?(slug: new_slug)
        new_slug = "#{base_slug}-#{counter}"
        counter += 1
      end
      self.slug = new_slug
    elsif slug.present?
      param_slug = slug.parameterize.truncate(100, omission: "")
      self.slug = param_slug.presence || slug.strip
    end
  end
end
