require 'rails_helper'

RSpec.describe SchemaField, type: :model do
  let(:spark_field_names) do
    json = File.read(file_fixture('spark_sample_schema.json'))
    spark_schema = JSON.parse(json)
    spark_schema['fields'].map { |f| f['name'] }.sort
  end

  let(:table) { Arel::Table.new('view'.to_sym) }

  let(:nuts_field) do
    SchemaField.new(
      name: 'nuts',
      level: '0',
      levels: %w[0 1 2 3],
      drill: [nil, nil, nil, nil]
    )
  end

  let(:date_field) do
    SchemaField.new(
      name: 'date',
      level: 'year',
      levels: %w[month year],
      drill: [nil, nil]
    )
  end

  let(:hier_field) do
    SchemaField.new(
      name: 'hier',
      level: '3',
      levels: %w[1 2 3 4 5],
      drill: [nil, nil, nil, nil, nil]
    )
  end

  let(:simple_field) do
    SchemaField.new(
      name: 'simple',
      level: nil,
      levels: [],
      drill: []
    )
  end
  describe '#fullname' do
    it 'returns name with level for nuts fields' do
      expect(nuts_field.fullname).to match('nuts_0')
    end

    it 'returns name with level for year fields' do
      expect(date_field.fullname).to match('date_year')
    end

    it 'returns name with level for hierachical fields' do
      expect(hier_field.fullname).to match('hier_level_3')
    end

    it 'returns name with level for nuts fields' do
      expect(simple_field.fullname).to match('simple')
    end
  end
end
