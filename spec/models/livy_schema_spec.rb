require 'rails_helper'

RSpec.describe LivySchema, type: :model do
  subject { build :livy_schema }

  let(:table) { Arel::Table.new(:view) }

  describe '#initialize' do
    context 'when input schema is empty' do
      subject { LivySchema.new }

      it 'has an Arel::Table' do
        expect(subject.table).to be_an Arel::Table
      end
    end

    context 'when input schema is the reference schema' do
      it 'has an Arel:Table' do
        expect(subject.table).to be_an Arel::Table
      end
      it 'has fields' do
        expect(subject.fields.size).to eq 4
        expect(subject.fields).to all be_a SchemaField
      end
    end
  end

  describe '#select_nodes' do
    it 'can be used in arel statement' do
      sql = table.project(subject.select_nodes).to_sql.delete('"')
      expected = %{SELECT view.nuts_1 AS nuts, view.date_year AS date,
        view.reported_by AS reported_by, view.crime_type_level_2 AS crime_type,
        COUNT(*) AS count FROM view}.squish
      expect(sql).to eq(expected)
    end
  end

  describe '#group_nodes' do
    it 'can be used in arel statement' do
      sql = table.group(subject.group_nodes).to_sql.delete('"')

      expected = %(SELECT FROM view GROUP BY view.nuts_1, view.date_year,
        view.reported_by, view.crime_type_level_2).squish
      expect(sql).to eq(expected)
    end
  end

  describe '#where_nodes' do
    it 'is an Array of Arel::Nodes::Equality' do
      expect(subject.group_nodes).to be_an Array
      expect(subject.where_nodes).to all be_an Arel::Nodes::Equality
    end

    it 'can be used in arel statement' do
      sql = table.where(subject.where_nodes).to_sql.delete('"')

      expected = %(SELECT FROM view WHERE view.nuts_0 = 'UK',
        view.nuts_2 = 'UKI6', view.date_year = '2016-01-01').squish
      expect(sql).to eq(expected)
    end
  end

  describe '#to_sql' do
    it 'returns sql string' do
      expected = %{SELECT view.nuts_1 AS nuts, view.date_year AS date,
        view.reported_by AS reported_by, view.crime_type_level_2 AS crime_type,
        COUNT(*) AS count FROM view WHERE view.nuts_0 = 'UK' AND
        view.nuts_2 = 'UKI6' AND view.date_year = '2016-01-01'
        GROUP BY view.nuts_1, view.date_year, view.reported_by,
        view.crime_type_level_2}.squish
      expect(subject.to_sql.delete('"')).to eq(expected)
    end
  end
end
