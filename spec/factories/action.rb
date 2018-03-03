FactoryBot.define do
  factory :action, class: 'Action' do
    type 'NOOP'
    payload({})

    factory :connectivity_engine_action do
      type 'CONNECTIVITY_ENGINE'
      payload name: 'livy', connected: true, from: 0, total: 0, sessions: []
    end
  end
end
