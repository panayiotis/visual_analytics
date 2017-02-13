require 'rails_helper'

RSpec.describe LivyDaemonJob, type: :job do
  it 'fetches Livy status from localhost Livy server' do
    action = LivyDaemonJob.perform_now(daemon: false)
    expect(action).to include(:type, :payload)
    payload = action[:payload]
    expect(payload).to include(:from, :total, :sessions)
    expect(payload[:from]).to be_an(Integer)
    expect(payload[:total]).to be_an(Integer)
    expect(payload[:sessions]).to be_an(Array)
  end

  it 'resets the redis livy key if status changes' do
    $redis.set('livy', {}.to_json)
    LivyDaemonJob.perform_now(daemon: false)
    $redis.set('livy', {}.to_json)
    LivyDaemonJob.perform_now(daemon: false)
    livy_status = JSON.parse($redis.get('livy'), symbolize_names: true)
    expect(livy_status).to include(:from, :total, :sessions)
  end
end
