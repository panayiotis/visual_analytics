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

  let(:code) { build(:livy_schema).to_code }
  let(:adapter) { LivyAdapter.new }

  describe '.request' do
    context 'with the reference schema' do
      it 'returns a success action' do
        action = adapter.request(code)
        expect(action.type).to match('ENGINE_COMPUTATION')
        expect(action.payload[:state]).to match('success')
        expect(action.last?).to be_truthy
      end

      it 'accepts a block to which it yields each intermediate action' do
        book = double('book')
        expect(book).to receive(:hello)
          .with(kind_of(Action), anything, anything)
          .at_least(:once)
        adapter.request(code) do |action, schema, data|
          book.hello(action, schema, data)
        end
      end
    end
  end

  describe '.request_schema' do
    it 'returns the default schema' do
      actual = adapter.request_schema.new_schema
      expect(actual).to be_a Hash
      expect(actual[:fields].size).to be > 10
    end
  end
end
