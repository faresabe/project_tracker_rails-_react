require 'rails_helper'

RSpec.describe Project, type: :model do
  subject { build(:project) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w(not_started in_progress completed archived)) }
    it { is_expected.to validate_inclusion_of(:priority).in_array(%w(low medium high critical)) }

   
    it 'is invalid if end_date is before start_date' do
      subject.start_date = Date.tomorrow
      subject.end_date = Date.today
      expect(subject).to be_invalid
      
      expect(subject.errors[:end_date]).to include("must be after start date")
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:creator).class_name('User') }
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
    it { is_expected.to have_many(:project_members).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:project_members).source(:user) }
   
    it { is_expected.to have_many(:comments).dependent(:destroy) } 
  end
end