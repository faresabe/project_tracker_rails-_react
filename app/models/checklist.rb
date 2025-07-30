class Checklist < ApplicationRecord
  belongs_to :task

  validates :item, presence: true
  validates :task_id, presence: true
end
