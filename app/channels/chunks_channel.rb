class ChunksChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chunks_channel_#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # rubocop:disable all
  def request(action_hash)
    adapter = LivyAdapter.new
    schema_hash = action_hash.dig('payload', 'schema')
    livy_schema = LivySchema.new(schema_hash)
    sql = livy_schema.to_sql
    chunk = Chunk.find_or_initialize_by(
      code: sql,
      notebook: Notebook.first
    )

    if chunk.blob
      action = LivyAction.new(
        type: 'ENGINE_COMPUTATION',
        payload: {
          state: :success,
          location: "/notebooks/#{chunk.notebook.id}/chunks/#{chunk.id}.json"
        }
      )

      ActionCable.server.broadcast 'chunks_channel', action
    else
      time_a = Time.now.to_i
      adapter.request(livy_schema) do |action, _new_schema, sql, data|
        if action.success?
          time_b = Time.now.to_i
          json = data.to_json
          chunk.blob = json
          chunk.byte_size = json.size
          chunk.computation_time = time_b - time_a
          chunk.save
          action.payload[:location] =
            "/notebooks/#{chunk.notebook.id}/chunks/#{chunk.id}.json"
        end
        ActionCable.server.broadcast 'chunks_channel', action
      end
    end
  end
  # rubocop:enable all
end
