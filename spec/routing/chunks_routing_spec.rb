require 'rails_helper'

RSpec.describe ChunksController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/chunks')
        .to route_to 'chunks#index'
    end

    it 'routes to #show' do
      expect(get: 'chunks/uuid')
        .to route_to('chunks#show', key: 'uuid')
    end
  end
end
