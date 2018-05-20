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

  let(:adapter) { LivyAdapter.new }

  describe '#create_livy_session' do
    it 'creates a new spark session' do
      actual = adapter.create_livy_session
      expect(actual).to be_a Hash
      expect(actual).to include(:id, :state, :kind)
    end
  end

  describe '#run_code' do
    it 'runs a simple println statement' do
      action = adapter.run_code('println("{\"hello\": \"world\"}")')
      expect(action.payload).to include(:hello)
    end
  end

  describe '#request' do
    context 'with a mock argument' do
      it 'returns a success action' do
        action = adapter.request('mock argument', '/var/data/storage', true)
        expect(action.type).to match('ENGINE_COMPUTATION')
        expect(action.payload[:state]).to match('success')
        expect(action.last?).to be_truthy
      end

      it 'accepts a block to which it yields each intermediate action' do
        book = double('book')
        expect(book).to receive(:hello)
          .with(kind_of(Action))
          .at_least(:once)
        adapter.request('mock_argument', '/var/data/storage', true) do |action|
          book.hello(action)
        end
      end
    end
  end

  describe '#request_views' do
    it 'returns a hash with the views from Spark' do
      actual = adapter.request_views
      expect(actual).to be_an Array
      expect(actual.first).to include(:name, :tableType, :isTemporary)
    end
  end

end
