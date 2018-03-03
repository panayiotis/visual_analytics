class Action
  include ActiveModel::AttributeMethods

  class << self
    def from_cache(key)
      json = Redis.current.get key
      hash = JSON.parse json, symbolize_names: true
      new(hash)
    end
  end

  attr_accessor :type, :payload, :error, :meta

  def initialize(args = {})
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def as_json(*)
    to_h
  end

  def broadcast_to(channel)
    ActionCable.server.broadcast channel, self
    self
  end

  def cache_to(key)
    Redis.current.set(key, to_json)
    self
  end

  def stale?(key)
    to_json != Redis.current.get(key)
  end

  def to_h
    h = {}
    h[:type] = type
    h[:payload] = payload unless payload.nil?
    h[:error] = payload unless error.nil?
    h[:meta] = payload unless meta.nil?
    h
  end
end
