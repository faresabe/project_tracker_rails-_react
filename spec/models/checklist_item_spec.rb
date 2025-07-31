require 'rails_helper'

RSpec.describe ChecklistItem, type: :model do
  subject { build(:checklist_item) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:content) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:task) }
  end
end