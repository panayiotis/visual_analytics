class Notebook < ApplicationRecord
  belongs_to :user
  has_many :chunks, dependent: :destroy

  after_initialize do
    if new_record?
      self.state_json ||= '{}'
      self.public ||= false
    end
  end

  def state
    JSON.parse(state_json, symbolize_names: true)
  end

  def state=(hash)
    self.state_json = hash.to_json
  end

  def initial_redux_state
    { 'notebook' => as_json.except('state_json') }
      .merge(state.as_json)
  end
end
