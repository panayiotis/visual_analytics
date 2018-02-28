require 'rails_helper'

RSpec.describe Schema, type: :model do
  subject { build(:schema) }

  it 'has a factory' do
    expect(subject).to be_a(Schema)
  end

  describe '.from_json' do
    subject { Schema.from_json(File.read(file_fixture('schema.json'))) }
    it 'returns Schema' do
      expect(subject).to be_a(Schema)
    end
  end

  describe '#initialize' do
    context 'when input schema is empty' do
      subject { Schema.new }

      it 'creates empty schema' do
        expect(subject.empty?). to be_truthy
      end
    end

    context 'when input schema is the reference schema' do
      it 'creates schema with 4 fields' do
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

  describe '#from_spark' do
    context 'when receives the reference spark json' do
      let(:actual) do
        json = File.read(file_fixture('spark_sample_schema.json'))
        hash = JSON.parse(json, symbolize_names: true)
        Schema.from_spark(hash)
      end

      it 'returns a Schema with 7 fields' do
        expect(actual).to be_a Schema
        expect(actual.size).to equal(7)
      end

      it 'returns a Schema with the expected nuts field' do
        nuts_field = actual.fields.select(&:nuts?).first
        expect(nuts_field.levels).to contain_exactly('0', '1', '2', '3')
        expect(nuts_field.drill.size).to be == 4
      end
    end
  end
end
