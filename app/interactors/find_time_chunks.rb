class FindTimeChunks
  def initialize(entry_relations)
    @entry_relations = if entry_relations.respond_to?(:entries_in_range)
                         [entry_relations]
                       else
                         entry_relations
                       end
  end

  def in_year(year)
    @range = UberZeit.year_as_range(year)
    find_chunks_as_collection
  end
  def in_range(date_or_range)
    @range = date_or_range.to_range
    find_chunks_as_collection
  end
  alias_method :in_day, :in_range

  private

  def find_chunks_as_collection
    TimeChunkCollection.new(find_chunks)
  end

  def find_chunks
    @entry_relations.collect{ |entry_relation| find_chunks_in_entry_relation(entry_relation) }.flatten
  end

  def find_chunks_in_entry_relation(entry_relation)
    entries_in_range = entry_relation.entries_in_range(@range)
    entries_in_range.collect { |entry| chunkify(entry) }.flatten
  end

  def chunkify(entry)
    entry.occurrences_as_time_ranges(@range).collect do |occurrence_range|
      create_and_clip_chunk(occurrence_range, entry)
    end.compact
  end

  def create_and_clip_chunk(range, entry)
    intersected_range = range.intersect(@range)
    return nil if !intersected_range or intersected_range.duration <= 0

    duration =  if treat_duration_relative_to_daily_working_time?(entry)
                  duration_relative_to_daily_working_time(intersected_range.duration)
                else
                  nil
                end
    TimeChunk.new(range: intersected_range, time_type: entry.time_type, parent: entry, duration: duration)
  end

  def treat_duration_relative_to_daily_working_time?(entry)
    entry.kind_of?(Absence) && entry.time_type.treat_duration_relative_to_daily_working_time?
  end

  def duration_relative_to_daily_working_time(duration)
    duration.to_f / 24.hours * UberZeit::Config[:work_per_day]
  end
end

