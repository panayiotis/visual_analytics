FactoryBot.define do
  factory :chunk do
    sequence(:code) { |n| "select field_#{n} from table" }
    sequence(:byte_size) { |n| n }
    notebook
  end
end
