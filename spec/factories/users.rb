FactoryBot.define do
    factory :user do
      # Using Faker to generate realistic-looking data for tests
      email { Faker::Internet.email }
      password { 'password123' }
      password_confirmation { 'password123' }
    end
  end