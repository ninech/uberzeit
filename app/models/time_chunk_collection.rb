class TimeChunkCollection

  attr_reader :range

  def initialize(date_or_range, objects_to_scan)
    @chunks = []
    @range = date_or_range.to_range
    @objects_to_scan = if objects_to_scan.respond_to?(:to_a)
                         objects_to_scan
                       else
                         [objects_to_scan]
                       end
    scan
  end

  def total(*types)
    @chunks.inject(0.0) do |sum,chunk|
      if types.include?(chunk.time_type) || types.empty?
        sum += chunk.duration
      else
        sum
      end
    end
  end


  private
  def scan
    @objects_to_scan.each do |object|
      @chunks.concat object.find_chunks(@range)
    end
  end

end
