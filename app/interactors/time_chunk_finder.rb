class TimeChunkFinder

  attr_reader :chunks

  def initialize(object, date_or_range, time_type_scope)
    @object = object
    @range = date_or_range.to_range
    @time_type_scope = time_type_scope
    @chunks = []
    search
  end

  private

  def search
    scope_to_search_on = @object.scope_for(@time_type_scope)
    entries_in_range = scope_to_search_on.entries_in_range(@range)
    @chunks = entries_in_range.collect { |entry| chunkify(entry) }.flatten
  end

  def chunkify(entry)
    entry.occurrences_as_time_ranges(@range).collect do |occurrence_range|
      create_and_clip_chunk(occurrence_range, entry)
    end.compact
  end

  def create_and_clip_chunk(range, entry)
    intersected_range = range.intersect(@range)
    return nil if !intersected_range or intersected_range.duration <= 0
    TimeChunk.new(range: intersected_range, time_type: entry.time_type, parent: entry)
  end
end
