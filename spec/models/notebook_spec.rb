require 'rails_helper'

RSpec.describe Notebook, type: :model do
  it 'has a factory' do
    expect { create(:notebook) }.to_not raise_exception
  end
end
