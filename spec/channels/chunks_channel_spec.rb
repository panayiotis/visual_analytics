require 'rails_helper'

class TestConnection
  attr_reader :identifiers, :logger

  def initialize(identifiers_hash = {})
    @identifiers = identifiers_hash.keys
    @logger = ActiveSupport::TaggedLogging.new(
      ActiveSupport::Logger.new(StringIO.new)
    )

    # This is an equivalent of providing `identified_by :identifier_key`
    # in ActionCable::Connection::Base subclass
    identifiers_hash.each do |identifier, value|
      define_singleton_method(identifier) do
        value
      end
    end
  end
end

RSpec.describe ChunksChannel do
  subject(:channel) { described_class.new(connection, {}) }

  let(:current_user) { build(:user) }

  # Connection is `identified_by :current_user`
  let(:connection) { TestConnection.new(current_user: current_user) }

  let(:action_cable) { ActionCable.server }

  # ActionCable dispatches actions by the `action` attribute.
  # In this test we assume the payload was successfully parsed
  # (it could be a JSON payload, for example).
  let(:action_hash) do
    {
      'action' => 'request',
      'type' => 'type...',
      'payload' => {
        'notebook' => { 'id' => 1 },
        'schema' => build(:schema).to_h
      }
    }
  end

  it 'broadcasts an Action to chunks_channel at least 3 times' do
    expect(action_cable).to receive(:broadcast)
      .with('chunks_channel', kind_of(Action)).at_least(3).times
    channel.perform_action(action_hash)
  end
end
