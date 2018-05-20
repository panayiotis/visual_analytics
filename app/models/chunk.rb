class Chunk < ApplicationRecord
  belongs_to :notebook

  after_destroy do
    begin
      File.delete path
    rescue Exception # rubocop:disable Lint/RescueException
      logger.warn "Warning: failed to delete #{path}".yellow
    end

    begin
      File.delete "#{path}.gz"
    rescue Exception # rubocop:disable Lint/RescueException
      logger.warn "Warning: failed to delete #{path}.gz".yellow
    end
  end

  def to_param
    key
  end

  def path
    "/var/data/storage/#{key}.json"
  end
end
