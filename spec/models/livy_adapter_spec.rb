require 'rails_helper'

RSpec.describe LivyAdapter, type: :model do
  let(:statements) do
    responses = %i[waiting available_ok available_error]
    files = responses.map do |filename|
      text = file_fixture("livy_#{filename}_response.json").read
      JSON.parse(text, symbolize_names: true)
    end
    responses.zip(files).to_h
  end

  let(:livy_schema) { build :livy_schema }
  let(:adapter) { LivyAdapter.new }

  context 'simple select request' do
    it 'performs request' do

      action = adapter.request(livy_schema)
      expect(action.type).to match('ENGINE_COMPUTATION')
      expect(action.payload[:state]).to match('success')
      expect(action.last?).to be_truthy
    end

    it 'performs request with a block and parameter' do

      book = double('book')
      expect(book).to receive(:hello)
        .with(kind_of(Action), anything, kind_of(String), anything)
        .at_least(:once)
      adapter.request(livy_schema) do |action, schema, sql, data|
        book.hello(action, schema, sql, data)
      end
    end
  end
end
