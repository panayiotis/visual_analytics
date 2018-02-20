require 'rails_helper'

RSpec.describe Geojson, type: :model do
  subject { build :geojson }

  it 'has a factory' do
    expect(subject).to be_a Geojson
  end
end
