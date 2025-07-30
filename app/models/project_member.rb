class ProjectMember < ApplicationRecord
  belongs_to :project
  belongs_to :user
  enum role: {
    member: "member",
    viewer: "viewer",
    owner: "owner"
  }

  validates :user_id, uniqueness: { scope: :project_id, message: "is already a member of this project" }
  validates :role, presence: true
end
