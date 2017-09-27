namespace :data do

  desc "Generate gzip versions for assets in public/assets/data"
  task compress: :environment do
    Dir.chdir( Rails.root.join 'public', 'assets', 'data' ) do
      Dir.glob( '*.{csv,json,geojson}' ).each do |file|
        puts "#{file}.gz"
        Zlib::GzipWriter.open("#{file}.gz", Zlib::BEST_COMPRESSION) do |gz|
          gz.mtime = File.mtime(file)
          gz.orig_name = file
          gz.write IO.binread(file)
        end
      end
    end
  end

end
