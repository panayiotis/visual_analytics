class Schema
  class << self
    def from_json(json)
      new(JSON.parse(json, symbolize_names: true))
    end
  end
  attr_reader :type, :fields

  def initialize(type: '', fields: {}, view: 'view')
    valid_field_keys = %i[name level levels drill]
    @type = type
    @fields = fields.values.map do |field|
      SchemaField.new(field.slice(*valid_field_keys).merge(schema: self))
    end
    @view = view
  end

  def to_h
    {
      type: @type,
      fields: fields.map { |f| [f.name.to_sym, f.to_h] }.to_h,
      view: @view
    }
  end

  delegate :empty?, :size, to: :fields

  def as_json(_options = nil)
    to_h
  end
end
