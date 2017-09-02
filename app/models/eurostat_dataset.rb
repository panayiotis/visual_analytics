class EurostatDataset < Dataset

  after_initialize :populate_some_fields

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
      h[f]["type"] = "date" if f == "date"
    end
    h
  end

  def run query = {}
    @rows = Rails.cache.fetch( "#{name}:all", expires_in: 1.hour ) do
      puts "fetch #{name} from web".yellow
      gzip = Net::HTTP.get(URI.parse(uri))
      tsv = ActiveSupport::Gzip.decompress(gzip)

      # tsv example
      # unit,isced11,indic_wb,sex,age,time\geo EU EU28 BE
      # RTG,ED0-2,LEGTST,F,Y16-24,2013 4.8 e 4.8 e 5.2 3.4
      # RTG,ED0-2,LEGTST,F,Y16-24,2013 4.2 2.7 4.0 2.9 3.2
      tsv = tsv.split("\n").map{|s| s.split("\t")}

      countries = tsv.shift

      fields = countries.shift.split(",").push("nut_level_0").push("count")

      rows = tsv.map { |a|
        first_col = a.shift.split(",")

        a.each_with_index.map do |val,i|
         Array.new.concat(first_col).push(countries[i].strip).push(val.strip)
        end
      }
      .flatten(1)
      .map{ |a|
        h = Hash.new
        fields.each_with_index do |key,i|
          h[key]= a[i]
        end
        h
      }

      @rows = rows

      if respond_to?("run_#{name}".to_sym,true)
        send("run_#{name}".to_sym)
      end
    end

    @query = {}
    @sql = ''
    @levels = {}
    @total_rows = @rows.length
  end

  private

    def run_ilc_pw03
      @rows.delete_if{ |h|
        %w(EU28 EU).include?(h['nut_level_0']) ||
        %w(:).include?(h['value']) ||
        %w(TOTAL ED5_6).include?(h['isced11']) ||
        %w(Y_GE16).include?(h['age']) ||
        %w(T).include?(h['sex'])
      }
      .map{ |h|
        h.delete 'unit'
        date = h.delete 'time\\geo'
        h['date'] =  Date.strptime(date, '%Y')
        h['count'] = h['count'].to_f
        h
      }
    end

    def populate_some_fields
      self.uri = "http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/" +
        "BulkDownloadListing?downfile=data/#{name}.tsv.gz"
    end
end
