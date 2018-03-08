class GeojsonController < ApplicationController
  before_action :set_geojson, only: [:show]

  # GET /geojson/:level
  # GET /geojson/:level.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_geojson
      args = { dataset: params[:dataset] }
      if params.key?(:level)
        if params.key?(:like) # rubocop:disable Style/ConditionalAssignment
          args = {
            dataset: params[:dataset],
            level: params[:level],
            like: params[:like]
          }
        else
          args = { dataset: params[:dataset], level: params[:level] }
        end
      end
      @geojson = Geojson.new(args)
    end
end
