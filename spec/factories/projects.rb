FactoryBot.define do
    factory :project do
      title { Faker::Lorem.sentence }
      description { Faker::Lorem.paragraph }
      start_date { Faker::Date.backward(days: 30) }
      end_date { Faker::Date.forward(days: 30) }
      status { %w(not_started in_progress completed).sample }
      priority { %w(low medium high critical).sample }
      
      association :creator, factory: :user
    end
  end