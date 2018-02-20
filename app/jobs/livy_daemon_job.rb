class LivyDaemonJob < ApplicationJob
  queue_as :default

  def perform(daemon: true, sleep_time: 3)
    loop do
      begin
        res = http_request
      rescue StandardError => e
        logger.error(e)
        logger.error "try again in #{sleep_time * 5}s"
        sleep sleep_time * 5
        next
      end

      if res.code == '200'
        action = dispach_action(res.body)
        return action unless daemon
      else
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

    def dispach_action(livy_status_json)
      previous_livy_status_json = Redis.current.get 'livy'
      livy_status = JSON.parse livy_status_json, symbolize_names: true

      action = {
        type: 'LIVY',
        payload: livy_status,
        meta: { broadcasted: false }
      }

      if previous_livy_status_json != livy_status_json
        Redis.current.set('livy', livy_status_json)
        action[:meta] = { broadcasted: true }
        ActionCable.server.broadcast 'livy_channel', action
      end
      action
    end
end
