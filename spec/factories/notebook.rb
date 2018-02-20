FactoryBot.define do
  factory :notebook do
    sequence(:name) { |n| "test notebook #{n}" }
    user
  end
end
