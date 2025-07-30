class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :content, presence: true
  validates :user_id, presence: true
  validates :commentable_type, presence: true
  validates :commentable_id, presence: true
end
