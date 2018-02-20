class Chunk < ApplicationRecord
  attr_writer :blob

  belongs_to :notebook

  before_validation do
    self.key = Base64.urlsafe_encode64(code)
  end

  before_save do
    File.open(make_path, 'w') { |file| file.write(@blob) }
  end

  def blob
    @blob || File.read(path)
  end

  def path
    Rails.root.join(
      'storage',
      Rails.env.to_s,
      key[0..1],
      "#{key}.json"
    )
  end

  private
    def make_path
      path.tap { |path| FileUtils.mkdir_p File.dirname(path) }
    end
end
