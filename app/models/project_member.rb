class ProjectMember < ApplicationRecord
  belongs_to :project
  belongs_to :user
  enum role: { member: 1, viewer: 2, owner: 0 }

  validates :user_id, uniqueness: { scope: :project_id, message: "is already a member of this project" }
  validates :role, presence: true
end
