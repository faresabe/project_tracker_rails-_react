FactoryBot.define do
    factory :project_member do
      role { %w(owner member viewer).sample }
      association :user
      association :project
    end
  end