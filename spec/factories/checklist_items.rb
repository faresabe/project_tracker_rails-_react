FactoryBot.define do
    factory :checklist_item do
      content { Faker::Lorem.sentence }
      completed { [true, false].sample }
      association :task
    end
  end