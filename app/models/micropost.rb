class Micropost < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :picture_size
  
  has_many :favorites, foreign_key: 'micropost_id', dependent: :destroy
  has_many :favorite_users, through: :favorites, source: :user
  
  mount_uploader :picture, PictureUploader
  
  def favorite?(user)
    favorite_users.include?(user)
  end

  private
    # アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
