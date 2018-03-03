require 'rails_helper'

RSpec.describe LivyDaemonJob, type: :job do
  it 'fetches Livy status from the localhost Livy server' do
    action = LivyDaemonJob.perform_now(daemon: false)
    expect(action).to be_an Action
    expect(action.type).to be == 'CONNECTIVITY_ENGINE'
    expect(action.payload[:from]).to be_an Integer
    expect(action.payload[:total]).to be_an Integer
    expect(action.payload[:sessions]).to be_an Array
    expect(action.payload[:connected]).to be == true
  end
end
