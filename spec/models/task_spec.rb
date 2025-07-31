require 'rails_helper'

RSpec.describe Task, type: :model do
  subject { build(:task) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w(not_started in_progress completed)) }
    it { is_expected.to validate_inclusion_of(:priority).in_array(%w(low medium high critical)) }
    
    it 'is invalid if due_date is in the past' do
      subject.due_date = 1.day.ago
      expect(subject).to be_invalid
      expect(subject.errors[:due_date]).to include("can't be in the past")
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    
    it { is_expected.to belong_to(:assignee).class_name('User').optional }
    it { is_expected.to have_many(:checklist_items).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
  end

 
  describe '#progress_percentage' do
   
    let(:task) { create(:task) }
    
   
    before do
     
      create_list(:checklist_item, 3, task: task, completed: false)
      create_list(:checklist_item, 2, task: task, completed: true)
    end

    it 'calculates the correct percentage of completed checklist items' do
      
      expect(task.progress_percentage).to eq(40) 
    end

    context 'when there are no checklist items' do
      let(:task_without_items) { create(:task) }
      it 'returns 0' do
        expect(task_without_items.progress_percentage).to eq(0)
      end
    end
  end
end