require 'rails_helper'

RSpec.describe Comment, type: :model do
  subject { build(:comment) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    
   
    it { is_expected.to belong_to(:commentable) }
  end

  describe 'polymorphic behavior' do
    
    let(:project) { create(:project) }
    let(:task) { create(:task) }

   
    context 'when commenting on a Project' do
      let(:comment_on_project) { create(:comment, commentable: project) }
      
      it 'returns the correct commentable object' do
        expect(comment_on_project.commentable).to eq(project)
      end
    end

    context 'when commenting on a Task' do
      let(:comment_on_task) { create(:comment, commentable: task) }

      it 'returns the correct commentable object' do
        expect(comment_on_task.commentable).to eq(task)
      end
    end
  end
end
