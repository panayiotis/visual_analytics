require 'rails_helper'

RSpec.describe Schema, type: :model do
  subject { build(:schema) }

  it 'has a factory' do
    expect(subject).to be_a(Schema)
  end

  describe '.from_json' do
    subject { Schema.from_json(File.read(file_fixture('schema.json'))) }
    it 'is expected to return Schema' do
      expect(subject).to be_a(Schema)
    end
  end

  describe '#initializate' do
    context 'when input schema is empty' do
      subject { Schema.new }

      it '#empty? is true' do
        expect(subject.empty?). to be_truthy
      end
    end

    context 'when input schema is the reference schema' do
      it 'has 4 fields' do
        expect(subject.size).to equal(4)
        expect(subject.empty?).to be_falsey
      end
    end
  end

  describe '#as_json' do
    it 'returns the same json it was given as input' do
      expected = File.read(file_fixture('schema.json'))
      actual = Schema.from_json(expected).to_json
      expect(actual.tr("\n ", ''))
        .to eq(expected.tr("\n ", ''))
    end
  end
end
