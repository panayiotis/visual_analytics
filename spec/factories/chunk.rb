FactoryBot.define do
  factory :chunk do
    sequence(:id) { |n| n }
    sequence(:byte_size) { |n| n }
    sequence(:key) { |n| "key-#{n}" }
    notebook

    factory :chunk_with_json do
      after :create do |chunk|
        # an empty json file is needed for request specs
        File.open(chunk.path, 'w') { |file| file.write('{}') }
      end
    end
  end
end
