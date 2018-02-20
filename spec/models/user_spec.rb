require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a factory' do
    expect { create(:user) }.to_not raise_exception
  end
end
