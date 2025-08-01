

require 'rails_helper'


RSpec.describe Checklist, type: :model do
  
  it { is_expected.to validate_presence_of(:item) }
end
