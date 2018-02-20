FactoryBot.define do
  factory :livy_schema, class: 'LivySchema' do
    initialize_with do
      LivySchema.from_json File.read('./spec/fixtures/files/schema.json')
    end
  end
end
