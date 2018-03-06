class LivyDaemonJob < ApplicationJob
  queue_as :default

  def perform(daemon: true, sleep_time: 1.0)
    loop do
      begin
        res = http_request
      rescue StandardError => e
        action = dispatch_error_action
        return action unless daemon
        logger.error(e)
        sleep sleep_time * 5
        next
      end

      if res.code == '200'
        action = dispatch_success_action(res.body)
        return action unless daemon
      else
        dispatch_error_action
        logger.error 'could not fetch sessions from Livy server'
        raise 'could not fetch sessions from Livy server' unless daemon
      end
      sleep sleep_time
    end
  end

  private
    def http(uri)
      @http ||= Net::HTTP.new(uri.host, uri.port)
    end

    def http_request
      uri = URI('http://localhost:8998/sessions')
      req = Net::HTTP::Get.new(uri.path, 'Accept' => 'application/json')
      http(uri).request(req)
    end

    def dispatch(action)
      ActionCable.server.broadcast 'livy_channel', action
      action
    end

    def dispatch_success_action(livy_status_json)
      livy_status = JSON.parse livy_status_json, symbolize_names: true
      action = Action.new(
        type: 'CONNECTIVITY_ENGINE',
        payload: { name: 'livy', connected: true, total: 0, sessions: [] }
          .merge(livy_status)
      )
      if action.stale?('livy')
        action.broadcast_to('livy_channel')
        action.cache_to('livy')
      end
      action
    end

    def dispatch_error_action
      action = Action.new(
        type: 'CONNECTIVITY_ENGINE',
        payload: { name: 'livy', connected: false, total: 0, sessions: [] }
      )
      if action.stale?('livy')
        action.broadcast_to('livy_channel')
        action.cache_to('livy')
      end
      action
    end
end
