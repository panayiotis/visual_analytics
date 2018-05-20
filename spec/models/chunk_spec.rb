require 'rails_helper'

RSpec.describe Chunk, type: :model do
  it 'has a factory' do
    expect { create(:chunk) }.to_not raise_exception
  end
end
