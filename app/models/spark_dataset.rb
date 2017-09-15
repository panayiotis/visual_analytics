class SparkDataset < Dataset

  def schema
    spark_schema = JSON.parse(schema_json)
    fields = {}
    spark_schema.each do |field|
      if field["name"].include? '_level_'
        res = field["name"].scan(%r{(.+)_level_(\d+)})[0]
        key = res[0]
        level = res[1].to_i
        if fields.has_key? key
          fields[key]["levels"].push(level)
        else
          fields[key] = field
          fields[key]["name"]=key
          fields[key]["levels"]= [  ]
          fields[key]["levels"].push level
        end
      else
        key = field["name"]
        fields[key] = field
      end
    end

    fields.each do |key,value|
      if value.has_key? "levels"
        value["levels"].sort!
      end
    end

    fields
  end

  def run query = {}
    puts "DATA".red

    # "SELECT nut_level_0 as nut, esco_level_2 as esco, grab_month as date, COUNT(*) as count FROM table WHERE esco_level_1 == \"Professionals\" GROUP BY nut_level_0, esco_level_2, grab_month"
    table = Arel::Table.new(name.to_sym)

    select_nodes = []
    group_nodes = []

    levels = {}

    schema.each do |name, field|
      if field.has_key? "levels"
        if query.has_key?(name)
          levels[name] = query[name]["level"].to_i + 1
        else
          levels[name] = field["levels"].first
        end
      end
    end

    schema.each do |name, field|
      if field.has_key? "levels"
        select_nodes.push table["#{name}_level_#{levels[name]}".to_sym].as(name)
        group_nodes.push table["#{name}_level_#{levels[name]}".to_sym]
      else
        select_nodes.push table[field["name"].to_sym]
        group_nodes.push table[field["name"].to_sym]
      end
    end
    select_nodes.push Arel.sql("*").count.as("count")

    arel_query = table.project select_nodes

    query.each do |name, value|
      ap name
      ap value
      node = table["#{name}_level_#{value["level"]}"].eq(value["key"])
      arel_query = arel_query.where node
    end

    arel_query = arel_query.group(group_nodes)

    sql = arel_query.to_sql.gsub('"','')

    puts sql.yellow

    jar = Rails.root.join 'vendor', 'eurostat.jar'
    cmd = "spark-submit --master local[4] '#{jar}' '#{name}' '#{uri}' \"#{sql}\""

    puts cmd.red

    out = Rails.cache.fetch( "#{name}:#{sql}", expires_in: 12.hours ) do
      out, err, st = Open3.capture3(cmd)
      if out.empty?
        raise StandardError, "Spark error", err.to_s
      end
      out
    end
    @query = query
    @rows = JSON.parse(out)
    @sql = sql
    @levels = levels
    @total_rows = @rows.length
  end

end
