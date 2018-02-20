FactoryBot.define do
  factory :schema do
    initialize_with do
      Schema.from_json File.read('./spec/fixtures/files/schema.json')
    end
  end
end
