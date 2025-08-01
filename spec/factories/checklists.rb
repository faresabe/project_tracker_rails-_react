FactoryBot.define do
  factory :checklist do
    # Faker generates a random sentence for the 'item' attribute.
    item { Faker::Lorem.sentence } 
    completed { [true, false].sample }
    association :task
  end
end
