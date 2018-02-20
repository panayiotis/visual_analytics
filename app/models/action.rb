class Action
  attr_accessor :type, :payload, :error, :meta

  def initialize(type: 'EMPTY', payload: nil, error: nil, meta: nil)
    @type = type
    @payload = payload
    @error = error
    @meta = meta
  end

  def to_h
    h = {}
    h[:type] = type
    h[:payload] = payload unless payload.nil?
    h[:error] = payload unless error.nil?
    h[:meta] = payload unless meta.nil?
    h
  end

  def as_json(*)
    to_h
  end
end
