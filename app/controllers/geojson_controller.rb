class GeojsonController < ApplicationController
  before_action :set_geojson, only: [:show]

  #layout 'dashboard'

  # GET /geojson/:level
  # GET /geojson/:level.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_geojson
      if params.has_key?(:level)
        if params.has_key?(:like)
          @geojson = Geojson.new(dataset: params[:dataset], level: params[:level],like: params[:like])
        else
          @geojson = Geojson.new(dataset: params[:dataset], level: params[:level])
        end
      else
          @geojson = Geojson.new(dataset: params[:dataset])
      end
    end

end
