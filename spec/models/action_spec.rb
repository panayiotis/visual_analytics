require 'rails_helper'

RSpec.describe Action, type: :model do
  it 'responds to to_h' do
    action = Action.new(type: 'ACTION_TYPE', payload: {}, meta: {})
    h = action.to_h
    expect(h).to be_a(Hash)
    expect(h).to include(:type, :payload, :meta)
    expect(h[:type]).to match('ACTION_TYPE')
  end
end
