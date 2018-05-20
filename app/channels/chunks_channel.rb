class ChunksChannel < ApplicationCable::Channel
  def subscribed
    @notebook = Notebook.find(params.dig('notebook', 'id'))
    @channel_name = "chunks:#{@notebook.id}:#{current_user.id}"
    @adapter = LivyAdapter.new
    stream_from @channel_name
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # rubocop:disable all
  def request(request_data)
    request_data.deep_symbolize_keys!
    # ap request_data
    key = request_data[:key]
    chunk = Chunk.find_by(
      key: key,
      notebook: @notebook
    )

    if chunk # chunk is cached
      Action.new(
        type: 'ENGINE_COMPUTATION',
        payload: {
          state: :success,
          cached: true,
          location: "/chunks/#{chunk.key}"
        }
      ).broadcast_to @channel_name

      Action.new(
        type: 'DATA',
        payload: {
          fetch_path: "/chunks/#{chunk.key}.json"
        }
      ).broadcast_to @channel_name

      Action.new(
        type: 'CHUNK',
        payload: chunk.as_json
      ).broadcast_to @channel_name

    else # perform request

      chunk = Chunk.new(notebook: @notebook)

      time_a = Time.now.to_i
      @adapter.request(request_data.except(:action,:key),
                       '/var/data/storage',
                       Rails.env.test?) do |action|
        if action.success?
          time_b = Time.now.to_i
          key = action.payload.dig(:key)

          chunk = Chunk.find_or_initialize_by(
            key: key,
            notebook: @notebook
          )
          is_cached = chunk.persisted?
          unless chunk.persisted?
            chunk.computation_time = time_b - time_a
            chunk.save
          end

          action.payload = action.payload.except(:file).merge({
            cached: is_cached,
            location: "/chunks/#{chunk.key}.json"
          })
          # ap action.to_h # for debug
          ActionCable.server.broadcast @channel_name, action

          Action.new(
            type: 'DATA',
            payload: {
              fetch_path: "/chunks/#{chunk.key}.json"
            }
          ).broadcast_to @channel_name

          Action.new(
            type: 'CHUNK',
            payload: chunk.as_json
          ).broadcast_to @channel_name
        else
          action.broadcast_to @channel_name
        end
      end
    end
    chunk
  end
end
