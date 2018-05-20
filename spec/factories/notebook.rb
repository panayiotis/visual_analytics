FactoryBot.define do
  factory :notebook do
    sequence(:name) { |n| "test notebook #{n}" }
    user

    factory :notebook_with_chunks do
      transient do
        chunks_count 5
      end

      after(:create) do |notebook, evaluator|
        create_list(:chunk, evaluator.chunks_count, notebook: notebook)
      end
    end

  end
end
