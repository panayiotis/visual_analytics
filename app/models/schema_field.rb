class SchemaField
  class << self
    def nuts?(name)
      /^nuts_\d+/i =~ name
    end

    def date?(name)
      /^date_.+/i =~ name
    end

    def basename(name)
      case name
      when /^nuts_\d$/i
        'nuts'
      when /^date_.+/i
        'date'
      when /.+_level_.+/i
        matchdata = /(.+)(?:_level_.*)$/i.match(name)
        matchdata[1]
      else
        name
      end
    end

    def level(name)
      case name
      when /^nuts_\d$/i
        matchdata = /^nuts_(\d)$/i.match(name)
        matchdata[1]
      when /^date_.+/
        matchdata = /^date_(.+)$/i.match(name)
        matchdata[1]
      when /.+_level_.+/
        matchdata = /.+_level_(.+)$/i.match(name)
        matchdata[1]
      else # rubocop:disable Style/EmptyElse
        nil
      end
    end
  end

  attr_reader :name, :level, :levels, :drill

  def initialize(name: nil, level: nil, levels: [], drill: [], schema: nil)
    @name = name
    @level = level
    @levels = levels
    @drill = drill
    @schema = schema
  end

  def fullname
    name_with_level(level)
  end

  def name_with_level(level)
    return name unless hier?
    case name
    when 'nuts'
      "nuts_#{level}"
    when 'date'
      "date_#{level}"
    else
      "#{name}_level_#{level}"
    end
  end

  def hier?
    !level.nil?
  end

  def to_h
    { name: @name, level: @level, levels: @levels, drill: @drill }
  end
end
