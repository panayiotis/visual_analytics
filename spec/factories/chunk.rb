FactoryBot.define do
  factory :chunk do
    sequence(:id) { |n| n }
    sequence(:code) { |n| "select field_#{n} from table" }
    sequence(:byte_size) { |n| n }
    notebook

    factory :chunk_with_blob do
      after(:create) do |chunk, evaluator|
        chunk.blob = Forgery(:lorem_ipsum).words(10).to_json
        chunk.save
      end
    end
  end
end
