require 'open3'

class Geojson
  attr_accessor :type, :features

  def initialize(attributes = {}) # rubocop:disable Metrics/MethodLength
    options = {
      level: 0,
      dataset: 'nuts'
    }.merge(attributes)

    datasets = {
      nuts: {
        table_name: 'NUTS_RG_10M_2013',
        path: '/var/data/nuts/10/data/NUTS_RG_10M_2013.shp'
      },
      world: {
        table_name: 'NUTS_RG_60M_2013',
        path: '/var/data/nuts/60/data/NUTS_RG_60M_2013.shp'
      }
    }

    dataset_name = options[:dataset].downcase.to_sym

    dataset = datasets[:nuts]
    dataset = datasets[dataset_name] if dataset.key?(dataset_name)

    table = Arel::Table.new(dataset[:table_name].to_sym)

    # level_node = table['STAT_LEVL_'].eq(options[:level])
    query = table.project(Arel.sql('*'))
    # .where(level_node)

    if options.key?(:like)
      like_node = table['NUTS_ID'].matches("#{options[:like]}%")
      query = query.where like_node
    end
    sql = query.to_sql.delete('"')

    outfile = Rails.root.join('tmp', 'tmp_geojson.json').to_s
    infile = Rails.root.join(dataset[:path]).to_s
    cmd = "ogr2ogr -f GeoJSON -sql \"#{sql}\" #{outfile} #{infile}"
    key = "geojson:#{options[:dataset]}#{sql}"
    geojson = Rails.cache.fetch(key, expires_in: 1.hour) do
      FileUtils.rm_f(outfile)
      _out, _err, _st = Open3.capture3(cmd)
      JSON.parse(File.read(outfile))
    end

    @type = geojson['type']

    @features = geojson['features']
  end
end
