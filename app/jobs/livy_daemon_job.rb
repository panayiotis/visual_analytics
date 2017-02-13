class LivyDaemonJob < ApplicationJob
  queue_as :default

  def perform(daemon: true, sleep_time: 3)
    uri = URI('http://localhost:8998/sessions')
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Get.new(uri.path, 'Accept' => 'application/json')

    loop do
      res = http.request(req)

      if res.code == '200'
        previous_livy_status_json = $redis.get 'livy'
        livy_status_json = res.body
        livy_status = JSON.parse livy_status_json, symbolize_names: true

        action = {
          type: 'LIVY',
          payload: livy_status,
          meta: { broadcasted: false }
        }

        if previous_livy_status_json != livy_status_json
          $redis.set('livy', livy_status_json)
          action[:meta] = { broadcasted: true }
          ActionCable.server.broadcast 'livy_channel', action
        end

        return action unless daemon

      else
        puts 'could not fetch sessions from Livy server'.red
        ap res
        puts res.body.to_s.yellow
        raise 'could not fetch sessions from Livy server' unless daemon
      end
      sleep sleep_time
    end
  end
end
