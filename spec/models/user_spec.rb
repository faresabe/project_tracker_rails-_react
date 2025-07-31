require 'rails_helper'

RSpec.describe User, type: :model do
 
  subject { build(:user) }

 
  describe 'validations' do
   
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password_digest) }
    it { is_expected.to have_secure_password }

   
    it 'is invalid with a badly formatted email' do
      subject.email = 'badly-formatted-email'
     .
      expect(subject).to be_invalid
    end

    it 'is valid with a valid email' do
      subject.email = 'test@example.com'
      expect(subject).to be_valid
    end
  end

 
  describe 'associations' do
   
    it { is_expected.to have_many(:projects_created).class_name('Project').with_foreign_key('creator_id').dependent(:destroy) }
    it { is_expected.to have_many(:project_memberships).class_name('ProjectMember').dependent(:destroy) }
    it { is_expected.to have_many(:projects).through(:project_memberships) }
    it { is_expected.to have_many(:assigned_tasks).class_name('Task').with_foreign_key('assignee_id').dependent(:nullify) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end
end