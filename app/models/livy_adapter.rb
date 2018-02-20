class LivyAdapter
  class << self
    def status
      JSON.parse Redis.current.get('livy'), symbolize_names: true
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

  def request(request_data) # rubocop:disable Metrics/MethodLength
    raise 'LivyAdapter: Livy session has not started' if sessions.empty?

    uri = URI("http://localhost:8998/sessions/#{active_session_id}/statements")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')

    sql = LivySchema.new(request_data.dig('payload')).to_sql

    code = <<~CODE
      print(s"""{
        "schema": ${spark.sql("#{sql}").schema.json},
        "data": [
          ${spark.sql("#{sql}").coalesce(1).toJSON.collect().mkString(",\\n")}
        ]
      }""")
    CODE

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
      yield(action) if block_given?
      return action if action.last?
      sleep 1
    end
  end
end
