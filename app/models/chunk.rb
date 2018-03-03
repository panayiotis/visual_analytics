class Chunk < ApplicationRecord
  attr_writer :blob

  belongs_to :notebook

  before_validation do
    self.key = SecureRandom.uuid
  end

  before_save do
    File.open(make_path, 'w') { |file| file.write(blob) }
    Zlib::GzipWriter.open("#{path}.gz", Zlib::BEST_COMPRESSION) do |f|
      f.write blob
    end
  end

  after_destroy do
    File.delete path
    File.delete "#{path}.gz"
  end

  def to_param
    key
  end

  def blob
    if @blob
      @blob
    elsif File.exist?(path)
      @blob = File.read(path)
    end
  end

  def path
    Rails.root.join(
      'storage',
      Rails.env.to_s,
      "notebook_#{notebook.id}",
      "#{key}.json"
    )
  end

  private
    def make_path
      path.tap { |path| FileUtils.mkdir_p File.dirname(path) }
    end
end
