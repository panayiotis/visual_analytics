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
    schema_hash = request_data.dig(:schema)
    livy_schema = LivySchema.new(schema_hash)
    code = livy_schema.to_code
    sql = livy_schema.to_sql
    chunk = Chunk.find_or_initialize_by(
      code: sql,
      notebook: @notebook
    )

    if chunk.blob
      Action.new(
        type: 'ENGINE_COMPUTATION',
        payload: {
          state: :success,
          cached: true,
          location: "/chunks/#{chunk.key}.json"
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
    else
      time_a = Time.now.to_i
      @adapter.request(code) do |action, new_schema, data|
        if action.success?
          time_b = Time.now.to_i
          json = {schema: livy_schema.as_json, data: data}.to_json
          chunk.blob = json
          chunk.byte_size = json.size
          chunk.computation_time = time_b - time_a
          chunk.save

          action.payload = action.payload.merge({
            cached: false,
            location: "/chunks/#{chunk.key}.json"
          })
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
  end

  def request_initial_data(data)
    action = @adapter.request_schema
    spark_schema = action.new_schema
    schema_hash = LivySchema.from_spark(spark_schema).to_h
    request({"schema"=> schema_hash})
  end
  # rubocop:enable all
end
