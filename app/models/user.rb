class User < ApplicationRecord
    has_secure_password
    has_many :owned_projects, class_name: 'Project', foreign_key: 'owner_id',dependent: :destroy
    has_many :project_members, dependent: :destroy
    has_many :projects, through: :project_members
    has_many :assigned_tasks, class_name: 'Task', foreign_key: 'assignee_id'
    has_many :comments, dependent: :destroy
  
    validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, presence: true, length: { minimum: 6 }, on: :create
    validates :first_name, presence: true
    validates :last_name, presence: true

end
