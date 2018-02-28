class Action
  attr_accessor :type, :payload, :error, :meta

  def initialize(args)
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
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
