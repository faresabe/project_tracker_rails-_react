
class Task < ApplicationRecord
 
  belongs_to :project
  belongs_to :assignee, class_name: 'User', foreign_key: 'assignee_id', optional: true
  belongs_to :parent_task, class_name: 'Task', foreign_key: 'parent_task_id', optional: true
  has_many :subtasks, class_name: 'Task', foreign_key: 'parent_task_id', dependent: :destroy
  has_many :checklists, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  
  enum :status, { to_do: 'to_do', in_progress: 'in_progress', done: 'done' }
  enum :priority, { low: 'low', medium: 'medium', high: 'high' }


  validates :title, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :project_id, presence: true
end