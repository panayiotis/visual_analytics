require 'rails_helper'

RSpec.describe Chunk, type: :model do
  it 'has a factory' do
    expect { create(:chunk) }.to_not raise_exception
  end

  it 'saves a blob file' do
    FileUtils.rm_rf(Rails.root.join('storage', 'test'))
    chunk = build(:chunk)
    chunk.blob = 'hello world!'
    chunk.save
    expect(File.read(chunk.path)).to match('hello world!')
  end

  it 'reads the blob file' do
    chunk = build(:chunk)
    chunk.blob = 'hello world!'
    chunk.save
    expect(chunk.blob).to match('hello world!')
    id = chunk.id
    expect(Chunk.find(id).blob).to match('hello world!')
  end
end
