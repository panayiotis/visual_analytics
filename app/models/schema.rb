class Schema
  class << self
    def from_json(json)
      new(JSON.parse(json, symbolize_names: true))
    end

    def from_spark(hash)
      fullnames = hash[:fields].map { |f| f[:name] }.sort
      fields = {}
      fullnames.each do |fullname|
        name = SchemaField.basename(fullname).to_sym
        level = SchemaField.level(fullname)
        unless fields.key?(name)
          fields[name] = { name: name, level: nil, levels: [], drill: [] }
        end
        if level
          fields[name][:levels].push(level)
          fields[name][:drill].push(nil)
        end
      end
      new type: hash[:type], fields: fields
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
