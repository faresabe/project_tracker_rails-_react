FactoryBot.define do
    factory :task do
      title { Faker::Lorem.sentence(word_count: 3) }
      due_date { Faker::Date.forward(days: 15) }
      status { %w(not_started in_progress completed).sample }
      priority { %w(low medium high critical).sample }
      association :project
      
      assignee { nil }
    end
  end