class Project < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  has_many :tasks, dependent: :destroy
  has_many :project_members, dependent: :destroy
  has_many :members, through: :project_members, source: :user 
  has_many :comments, as: :commentable, dependent: :destroy

  enum status: { to_do: 'to_do', in_progress: 'in_progress', done: 'done' }
  enum priority: { low: 'low', medium: 'medium', high: 'high' }
  validates :title, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :end_date, comparison: { greater_than_or_equal_to: :start_date, message: "must be on or after the start date" }, if: -> { start_date.present? && end_date.present? }
end
