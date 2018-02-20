class ChunksChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chunks_channel_#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def request(data)
    adapter = LivyAdapter.new
    adapter.request(data) do |action|
      ActionCable.server.broadcast 'chunks_channel', action
    end
  end
end
