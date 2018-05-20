class LivyAdapter
  class << self
    def status
      Action.from_cache('livy').payload
    end
  end

  #  {
  #         name: "livy",
  #    connected: true,
  #        total: 0,
  #     sessions: [],
  #         from: 0
  #  }

  def status
    LivyAdapter.status
  end

  def sessions
    status[:sessions]
  end

  def active_session
    status.dig(:sessions).last
  end

  # Session example
  #  {
  #           id: 1,
  #        appId: nil,
  #        owner: nil,
  #    proxyUser: nil,
  #        state: "starting",
  #         kind: "spark",
  #      appInfo: {
  #      driverLogUrl: nil,
  #        sparkUiUrl: nil
  #    },
  #          log: [
  #      "stdout: ",
  #      "\nstderr: "
  #    ]
  #  }
  def create_livy_session
    host = 'http://localhost:8998'
    uri = URI("#{host}/sessions/")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')

    req.body = {
      kind: 'spark'
    }.to_json

    res = http.request(req)
    session = JSON.parse(res.body, symbolize_names: true)

    # if session is a String instead of a Hash it means that Livy raised
    # an exception
    raise "LivyException: #{session}" if session.is_a? String

    session
  end

  def get_or_create_livy_session # rubocop:disable Naming/AccessorMethodName
    active_session || create_livy_session
  end

  # TODO: Refactor method
  def request(json, path, mock)
    code = %{visual_analytics.Run("""#{json.to_json}""", \
      #{path.to_json}, #{mock} ) }.squish

    if block_given?
      run_code(code, &Proc.new)
    else
      run_code(code)
    end
  end

  def request_views
    code = 'visual_analytics.Run.views(mock=true)'
    run_code(code).payload.dig(:views)
  end

  def run_code(code) # rubocop:disable Metrics/MethodLength
    host = 'http://localhost:8998'

    # wait untill session becomes idle
    loop do
      break if get_or_create_livy_session.dig(:state) == 'idle'
      # puts "waiting until session becomes idle...".yellow
      # ap get_or_create_livy_session
      sleep 1.0
    end

    session_id = get_or_create_livy_session.dig(:id)

    uri = URI("#{host}/sessions/#{session_id}/statements")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')

    req.body = {
      kind: 'spark',
      code: code
    }.to_json

    res = http.request(req)
    statement_location = res['location']

    loop do
      uri = URI("http://livy:8998#{statement_location}")
      req = Net::HTTP::Get.new(uri.path, 'Accept' => 'application/json')
      res = http.request(req)
      statement_hash = JSON.parse(res.body, symbolize_names: true)
      # ap statement_hash
      action = LivyAction.new_from_response(statement_hash)
      # ap action.to_h

      # TODO: After method refactoring, move to task
      # code that writes responses to fixtures
      # path = Rails.root.join( 'spec', 'fixt:ures', 'files',
      #                        "livy_#{action.payload[:state]}_response.json")
      # File.open(path, 'w') do |f|
      #   f.write(JSON.pretty_generate(statement_hash))
      # end

      # data = nil
      # new_schema = nil
      if action.success?
        # data = action.data
        # new_schema = LivySchema.from_spark(action.new_schema)
      end

      yield(action) if block_given?

      return action if action.last?
      sleep 1.0
    end
  end
end
