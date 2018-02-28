module ChunksHelper
  def number_to_human_seconds(secs)
    [[60, :sec], [60, :min], [24, :hours], [1000, :days]].map do |count, name|
      if secs&.positive?
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    end
      .compact.reverse.join(' ')
  end
end
