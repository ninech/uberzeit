class TimeChunkCollection

  attr_reader :range, :chunks

  def initialize(date_or_range, objects_to_scan, time_type_scope = nil)
    @chunks = []
    @range = date_or_range.to_range
    @time_type_scope = time_type_scope
    @objects_to_scan = unless objects_to_scan.respond_to?(:find_chunks)
                         objects_to_scan
                       else
                         [objects_to_scan]
                       end
    scan
  end

  def total(*types)
    @chunks.inject(0.0) do |sum,chunk|
      if types.include?(chunk.time_type.kind) || types.empty?
        sum += chunk.duration
      else
        sum
      end
    end
  end


  private
  def scan
    @objects_to_scan.each do |object|
      @chunks.concat object.find_chunks(@range, @time_type_scope)
    end
  end

end
