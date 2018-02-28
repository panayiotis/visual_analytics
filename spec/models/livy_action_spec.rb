require 'rails_helper'

RSpec.describe LivyAction, type: :model do
  let(:statements) do
    responses = %i[waiting running success error]
    files = responses.map do |filename|
      text = file_fixture("livy_#{filename}_response.json").read
      JSON.parse(text, symbolize_names: true)
    end
    responses.zip(files).to_h
  end

  it 'can parse waiting statement fixture' do
    expect { LivyAction.new_from_response(statements[:waiting]) }
      .not_to raise_error
  end

  it 'can parse running statement fixture' do
    expect { LivyAction.new_from_response(statements[:running]) }
      .not_to raise_error
  end

  it 'can parse success statement fixture' do
    expect { LivyAction.new_from_response(statements[:success]) }
      .not_to raise_error
  end

  it 'can parse error statement fixture' do
    expect { LivyAction.new_from_response(statements[:error]) }
      .not_to raise_error
  end

  context 'on waiting statement' do
    subject { LivyAction.new_from_response(statements[:waiting]) }

    it '.new_from_response returns Hash payload with progress float' do
      expect(subject.payload).to be_a Hash
      expect(subject.payload).to include(:state, :progress)
      expect(subject.payload[:progress]).to be_a Float
    end

    it '#last? is false' do
      expect(subject.last?).to be_falsey
    end
  end

  context 'on running statement' do
    subject { LivyAction.new_from_response(statements[:running]) }

    it '.new_from_response returns Hash payload with progress float' do
      expect(subject.payload).to be_a Hash
      expect(subject.payload).to include(:state, :progress)
      expect(subject.payload[:progress]).to be_a Float
    end

    it '#last? is false' do
      expect(subject.last?).to be_falsey
    end
  end

  context 'on success statement' do
    subject { LivyAction.new_from_response(statements[:success]) }

    it '.new_from_response returns nil payload' do
      expect(subject.payload).to include(:state)
      expect(subject.payload.size).to be == 1
    end

    it '#success? is true' do
      expect(subject.success?).to be_truthy
    end

    it '#last? is true' do
      expect(subject.last?).to be_truthy
    end

    it '#data has a data Array' do
      expect(subject.data).to be_an Array
      expect(subject.data.size).to be == 59
    end
  end

  context 'on error statement' do
    subject { LivyAction.new_from_response(statements[:error]) }

    it '.new_from_response returns Hash payload with progress float' do
      expect(subject.error).to be_truthy
      expect(subject.payload).to be_a(Hash)
      expect(subject.payload).to include(:state, :output)
    end
  end
end
