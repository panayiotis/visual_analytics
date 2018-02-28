require 'rails_helper'

RSpec.describe Notebook, type: :model do
  subject { create(:notebook) }

  it 'has a factory' do
    expect { create(:notebook) }.to_not raise_exception
    expect(create(:notebook).errors.any?).to be_falsey
  end

  it 'has a _with_chunks factory' do
    expect(create(:notebook_with_chunks).chunks.count).to be == 5
  end

  it 'created with default variables' do
    subject { Notebook.create(name: 'test', user: create(:user)) }
    expect(subject.state).to be_a(Hash)
    expect(subject.state.size).to be == 0
  end

  describe '#state' do
    it 'returns a Hash' do
      n = create(:notebook, state_json: '{"hello": "world"}')
      expect(n.state).to be_a(Hash)
      expect(n.state).to include(:hello)
    end
  end

  describe '#state=' do
    it 'sets a Hash as state' do
      n = create(:notebook, state_json: '{"hello": "world"}')
      n.state = { hello: 'world' }
      expect(n.state_json).to match('{"hello":"world"}')
    end
  end

  describe '#initial_redux_state' do
    subject do
      create(:notebook, state_json: '{"key": "value"}')
        .initial_redux_state
    end
    it { should be_a Hash }
    it { should include 'key' => 'value' }
    it { should include 'notebook' }
  end
end
