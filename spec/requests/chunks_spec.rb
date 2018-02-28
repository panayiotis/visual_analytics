require 'rails_helper'

RSpec.describe 'Chunks', type: :request do
  # TODO: authenticate user before sending chunk
  describe 'GET /chunks' do
    it 'works' do
      create :notebook_with_chunks_with_blobs
      get chunks_path
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /chunks/:uuid' do
    it 'works' do
      chunk = create :chunk_with_blob
      get chunk_path(chunk)
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /chunks/:uuid.json' do
    it 'works' do
      chunk = create :chunk_with_blob
      get chunk_path(chunk, format: :json)
      expect(response.content_type).to eq('application/json')
      expect(response).to have_http_status(200)
    end
  end
end
