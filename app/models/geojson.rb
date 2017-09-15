require 'open3'

class Geojson
  attr_accessor :type, :features

  def initialize(attributes={})

    options = {
      level: 0,
      dataset: "nuts"
    }.merge(attributes)

    ap options

    datasets = {
      nuts: {
        table_name: "NUTS_RG_60M_2013",
        path: 'lib/assets/nuts/NUTS_2013_60M_SH/data/NUTS_RG_60M_2013.shp'
      },
      world: {
        table_name: "NUTS_RG_60M_2013",
        path: 'lib/assets/nuts/NUTS_2013_60M_SH/data/NUTS_RG_60M_2013.shp'
      }
    }

    dataset_name = options[:dataset].downcase.to_sym

    dataset = datasets[:nuts]
    if dataset.has_key?(dataset_name)
      dataset = datasets[dataset_name]
    end

    ap dataset

    table = Arel::Table.new(dataset[:table_name].to_sym)

    level_node = table["STAT_LEVL_"].eq(options[:level])

    query = table.project(Arel.sql('*'))
      .where(level_node)

    if options.has_key?(:like)
      like_node = table["NUTS_ID"].matches("#{options[:like]}%")
      query = query.where like_node
    end
    sql = query.to_sql.gsub('"','')

    outfile = Rails.root.join('tmp/tmp_geojson.json').to_s
    infile = Rails.root.join(dataset[:path]).to_s
    cmd = "ogr2ogr -f GeoJSON -sql \"#{sql}\" #{outfile} #{infile}"
    puts cmd
    geojson = Rails.cache.fetch( "geojson:#{options[:dataset]}#{sql}", expires_in: 1.second ) do
      FileUtils.rm_f(outfile)
      out, err, st = Open3.capture3(cmd)
      JSON.parse(File.read(outfile))
    end

    @type = geojson["type"]

    @features = geojson["features"]
  end

end
