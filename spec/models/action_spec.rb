require 'rails_helper'

RSpec.describe Action, type: :model do
  it 'has a factory' do
    action = build :action
    expect(action.type).to be == 'NOOP'
    expect(action.payload).to be_a Hash
  end

  describe '.from_cache' do
    it 'creates an action from Redis cache' do
      json = '{"type":"NOOP","payload":{}}'
      key = 'action_spec.rb'
      Redis.current.set(key, json)
      actual = Action.from_cache(key)
      expect(actual).to be_an Action
      expect(actual.to_json).to be == json
    end
  end

  describe '#stale? key' do
    context 'when the action is not in redis key' do
      it 'returns true' do
        key = 'action_spec.rb'
        Redis.current.set(key, 'helloworld')
        expect(build(:action).stale?(key)).to be_truthy
      end
    end

    context 'when the redis key does not exist' do
      it 'returns true' do
        key = 'action_spec.rb'
        Redis.current.del(key)
        expect(build(:action).stale?(key)).to be_truthy
      end
    end

    context 'when the redis key holds the same action' do
      it 'returns false' do
        key = 'action_spec.rb'
        Redis.current.set(key, build(:action).to_json)
        expect(build(:action).stale?(key)).to be_falsey
      end
    end
  end

  describe '#to_h' do
    it 'returns a hash with all instance variables ' do
      action = Action.new(type: 'ACTION_TYPE', payload: {}, meta: {})
      h = action.to_h
      expect(h).to be_a(Hash)
      expect(h).to include(:type, :payload, :meta)
      expect(h[:type]).to match('ACTION_TYPE')
    end
  end
end
