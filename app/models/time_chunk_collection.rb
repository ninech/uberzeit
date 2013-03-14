class TimeChunkCollection

  attr_reader :chunks

  def initialize(chunks = [])
    @chunks = chunks
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

  def length
    @chunks.length
  end

  def each(&block)
    @chunks.each do |chunk|
      yield chunk
    end
  end

  def map(&block)
    @chunks.map do |chunk|
      yield chunk
    end
  end

  def empty?
    @chunks.empty?
  end
end
