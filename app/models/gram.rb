class Gram < ActiveRecord::Base
  validates :message, presence: true
  validates :picture, presence: true

  has_many :comments

  belongs_to :user

  mount_uploader :picture, PictureUploader
end