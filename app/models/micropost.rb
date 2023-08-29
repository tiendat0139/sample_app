class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  validates :content, presence: true,
                      length: {maximum: Settings.digits.length_140}
  validates :image, content_type: {in: Settings.microposts.image_type,
                                   message: :invalid_image_type},
                    size: {less_than: 5.megabytes,
                           message: :limit_size}

  scope :newest, ->{order(created_at: :desc)}
  scope :by_user, ->(user_ids){where(user_id: user_ids)}

  delegate :name, to: :user, prefix: true

  def display_image
    image.variant resize_to_limit: Settings.microposts.resize_to_limit
  end
end
