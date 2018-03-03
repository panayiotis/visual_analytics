class LivySchema < Schema
  attr_reader :table

  def initialize(*args)
    super
    @table = Arel::Table.new(@view.to_sym)
  end

  def select_nodes
    fields.map { |field| table[field.fullname.to_sym].as(field.name) }
      .push(Arel.sql('*').count.as('count'))
      .compact
  end

  def group_nodes
    fields.map { |field| table[field.fullname.to_sym] }
      .compact
  end

  def where_nodes
    fields.map do |field|
      field.levels.zip(field.drill).map do |level, drill|
        drill && table[field.name_with_level(level)].eq(drill)
      end
    end.flatten.compact
  end

  def to_sql
    table.project(select_nodes)
      .group(group_nodes)
      .tap { |t| where_nodes.each { |w| t = t.where(w) } }
      .to_sql
      .delete('"')
  end

  def to_schema_json_sql
    table.project(Arel.sql('*'))
      .to_sql
      .delete('"')
  end

  def to_code
    <<~CODE
      print(s"""{
        "schema": ${spark.sql("#{to_schema_json_sql}").schema.json},
        "data": [
          ${spark.sql("#{to_sql}").coalesce(1).toJSON.collect().mkString(",\\n")}
        ]
      }""")
    CODE
  end
end
