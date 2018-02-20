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
  let(:request_action) do
    {
      'action' => 'request',
      'type' => 'type...',
      'payload' => build(:schema).to_h
    }
  end

  context 'simple select request' do
    it 'performs request' do
      l = LivyAdapter.new
      action = l.request(request_action)
      expect(action.type).to match('STATEMENT_AVAILABLE')
      expect(action.last?).to be_truthy
    end

    it 'performs request with a block and parameter' do
      l = LivyAdapter.new
      book = double('book')
      expect(book).to receive(:hello).with(kind_of(Action)).at_least(:once)
      l.request(request_action) { |action| book.hello(action) }
    end
  end
end
