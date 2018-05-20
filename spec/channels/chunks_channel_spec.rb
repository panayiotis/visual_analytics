require 'rails_helper'

class TestConnection
  attr_reader :identifiers, :logger, :server

  # https://github.com/rails/rails/blob/master/actioncable/lib/action_cable/connection/base.rb
  def initialize(identifiers_hash = {})
    @identifiers = identifiers_hash.keys
    @logger = ActiveSupport::TaggedLogging.new(
      ActiveSupport::Logger.new(StringIO.new)
    )
    @server = ActionCable.server

    # This is an equivalent of providing `identified_by :identifier_key`
    # in ActionCable::Connection::Base subclass
    # https://github.com/rails/rails/blob/master/actioncable/lib/action_cable/connection/identification.rb
    identifiers_hash.each do |identifier, value|
      define_singleton_method(identifier) do
        value
      end
    end
  end
end

RSpec.describe ChunksChannel do
  let(:notebook) { create :notebook }
  let(:current_user) { create(:user) }
  let(:identifier) { "identifier:#{Forgery(:basic).text}" }
  let(:channel_name) { "chunks:#{notebook.id}:#{current_user.id}" }
  let(:server) { ActionCable.server }
  subject(:channel) { described_class.new(connection, identifier, params) }
  let(:connection) { TestConnection.new(current_user: current_user) }
  let(:action_cable) { ActionCable.server }

  let(:params) do
    HashWithIndifferentAccess.new(notebook: notebook.as_json)
  end

  # ActionCable dispatches actions by the `action` attribute.
  let(:data) do
    {
      'action' => 'request',
      'notebook' => { 'id' => notebook.id },
      'schema' => build(:schema).to_h,
      'key' => 'view63c55'
    }
  end

  describe '#request data' do
    it 'broadcasts an Action to chunks_channel at least 3 times' do
      expect(action_cable).to receive(:broadcast)
        .with(channel_name, kind_of(Action)).at_least(2).times
      channel.subscribed
      channel.perform_action(data)
    end
  end
end
