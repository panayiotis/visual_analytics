require 'rails_helper'

RSpec.describe LivyAction, type: :model do
  let(:statements) do
    responses = %i[waiting available_ok available_error]
    files = responses.map do |filename|
      text = file_fixture("livy_#{filename}_response.json").read
      JSON.parse(text, symbolize_names: true)
    end
    responses.zip(files).to_h
  end

  context 'receives waiting statement' do
    it 'creates Action' do
      action = LivyAction.new_from_response(statements[:waiting])
      expect(action.payload).to be_a(Float)
      expect(action.type).to match('STATEMENT_WAITING')
    end
  end

  context 'receives available and ok statement' do
    it 'creates Action' do
      action = LivyAction.new_from_response(statements[:available_ok])

      expect(action.type).to match('STATEMENT_AVAILABLE')
      expect(action.payload).to be_a(Hash)
      expect(action.payload).to include(:schema, :data)
    end
  end

  context 'receives available and error statement' do
    it 'creates action' do
      action = LivyAction.new_from_response(statements[:available_error])
      expect(action.error).to be_truthy
      expect(action.type).to match('STATEMENT_ERROR')
      expect(action.payload).to be_a(Hash)
      expect(action.payload).to include(:evalue, :traceback)
    end
  end
end
