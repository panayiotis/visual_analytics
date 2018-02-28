class NotebookChannel < ApplicationCable::Channel
  def subscribed
    # TODO: needs testing with a js client
    notebook = Notebook.find_by(id: params.dig('notebook', 'id'))
    stream_from "#{notebook.adapter}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def unfollow
    stop_all_streams
  end
end
