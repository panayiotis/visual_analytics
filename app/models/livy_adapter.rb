class LivyAdapter
  class << self
    def status
      Action.from_cache('livy').payload
    end
  end

  def initialize
    @status = LivyAdapter.status
  end

  def status
    @status ||= LivyAdapter.status
  end

  def sessions
    status[:sessions]
  end

  def active_session_id
    status.dig(:sessions).last.dig(:id) unless sessions.empty?
  end

  # TODO: Refactor method
  def request(code) # rubocop:disable Metrics/MethodLength
    raise 'LivyAdapter: Livy session has not started' if sessions.empty?

    uri = URI("http://localhost:8998/sessions/#{active_session_id}/statements")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')

    req.body = {
      kind: 'spark',
      code: code
    }.to_json

    res = http.request(req)
    statement_location = res['location']
    loop do
      uri = URI("http://localhost:8998#{statement_location}")
      req = Net::HTTP::Get.new(uri.path, 'Accept' => 'application/json')
      res = http.request(req)
      statement_hash = JSON.parse(res.body, symbolize_names: true)
      action = LivyAction.new_from_response(statement_hash)

      # TODO: After method refactoring, move to task
      # code that writes responses to fixtures
      # path = Rails.root.join( 'spec', 'fixtures', 'files',
      #                        "livy_#{action.payload[:state]}_response.json")
      # File.open(path, 'w') do |f|
      #   f.write(JSON.pretty_generate(statement_hash))
      # end

      data = nil
      new_schema = nil
      if action.success?
        data = action.data
        new_schema = LivySchema.from_spark(action.new_schema)
      end

      yield(action, new_schema, data) if block_given?

      return action if action.last?
      sleep 1.0
    end
  end

  def request_schema(view: 'view')
    code = <<~CODE
      print(s"""{
        "schema": ${spark.sql("select * from #{view} limit 1").schema.json},
        "data": [
        ]
      }""")
    CODE
    request(code)
  end
end
