require 'rails_helper'

RSpec.describe ProjectMember, type: :model do
 
  let!(:existing_project_member) { create(:project_member) }
  subject { build(:project_member, user: existing_project_member.user, project: existing_project_member.project) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_inclusion_of(:role).in_array(%w(owner member viewer)) }
    
    
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:project_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:project) }
  end
end
