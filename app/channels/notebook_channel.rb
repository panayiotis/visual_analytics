class NotebookChannel < ApplicationCable::Channel
  def subscribed
    @notebook = Notebook.find_by(id: params.dig('notebook', 'id'))
    stream_from "#{@notebook.adapter}_channel"
    stream_from "notebook:#{@notebook.id}"
    Action.from_cache(@notebook.adapter)
      .broadcast_to("notebook:#{@notebook.id}")
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def unfollow
    stop_all_streams
  end

  def invalidate_cache
    @notebook.chunks.destroy_all
  end
end
