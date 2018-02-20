require 'rails_helper'

RSpec.describe 'Chunks', type: :request do
  describe 'GET /chunks' do
    it 'works! (now write some real specs)' do
      get chunks_path
      expect(response).to have_http_status(200)
    end
  end
end
