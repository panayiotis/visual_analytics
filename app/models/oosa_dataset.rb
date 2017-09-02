require 'csv'
class OosaDataset < Dataset

  #after_initialize :populate_some_fields

  def schema
    h = Hash.new
    datum = rows.first

    return {} if datum.nil?

    fields = datum.keys
    fields.each do |f|
      h[f] = {
        "name" => f,
        "type" => "string",
        "nullable" => false,
        "metadata" => {}
      }
      h[f]["type"] = "float" if datum[f].is_a?(Float)
      h[f]["type"] = "integer" if datum[f].is_a?(Integer)
      h[f]["type"] = "date" if f == "date"
    end
    h
  end

  def run query = {}
    data =  CSV.read(Rails.root.join("lib/assets/oosa.csv"))
    ap keys = data.shift

    @rows = data.map{|a| Hash[keys.zip(a)]}.map do |h|
      h["date"] = Date.strptime(h["date"], '%Y') + 1.day
      h["count"] = h["count"].to_i
      h
    end

    @query = {}
    @sql = ''
    @levels = {}
    @total_rows = @rows.length
  end
end
