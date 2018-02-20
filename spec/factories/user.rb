FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "factory_user_#{n}" }
    password 'password'
  end
end
