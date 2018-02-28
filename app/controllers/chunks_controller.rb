class ChunksController < ApplicationController
  before_action :set_chunk, only: %i[show]
  # TODO: authenticate user

  # GET /chunks
  # GET /chunks.json
  def index
    @chunks = Chunk.all
  end

  # GET /chunks/1
  # GET /chunks/1.json
  def show
    respond_to do |format|
      format.html {}
      format.json { send_file @chunk.path, disposition: :inline }
    end
  end

  # DELETE /chunks/1
  # DELETE /chunks/1.json
  def destroy
    @chunk.destroy
    respond_to do |format|
      format.html {
        redirect_to chunks_url, notice: 'Chunk was successfully destroyed.'
      }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chunk
      @chunk = Chunk.find_by(key: params[:key])
    end
end
