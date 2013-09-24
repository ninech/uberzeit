class TimeChunkCollection

  attr_reader :chunks
  attr_reader :ignore_exclusion_flag

  def initialize(chunks = [])
    @chunks = chunks.dup
  end

  def total
    total_for_time_chunks + total_for_date_chunks
  end

  # skip exclude_from_calculation? check of chunks or their time type
  def ignore_exclusion_flag=(yes_or_no)
    @ignore_exclusion_flag = yes_or_no
  end

  def bonus
    total_bonus_for_time_chunks
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

  private

  def date_chunks
    chunks.select { |chunk| chunk.half_day_specific? }
  end

  def time_chunks
    chunks.reject { |chunk| chunk.half_day_specific? }
  end

  def time_chunks_for_calculation
    time_chunks.select { |chunk| !chunk.exclude_from_calculation? || ignore_exclusion_flag? }
  end

  def date_chunks_for_calculation
    date_chunks.select { |chunk| !chunk.exclude_from_calculation? || ignore_exclusion_flag? }
  end

  def total_for_time_chunks
    time_chunks_for_calculation.inject(0.0) { |sum,chunk| sum + round(chunk.duration) }
  end

  def total_bonus_for_time_chunks
    time_chunks.inject(0.0) { |sum,chunk| sum + round(chunk.time_bonus) }
  end

  # make sure we only count chunks on the same date once
  def total_for_date_chunks
    @chunks_on_date = {}

    date_chunks_for_calculation.each do |chunk|
      date_range = chunk.range.to_date_range
      date_range.each { |date| put_chunk_on_date(date, chunk) }
    end

    @chunks_on_date.inject(0.0) do |sum,(date,date_chunks)|
      sum + chunks_on_date_to_working_time(date, date_chunks)
    end
  end

  def put_chunk_on_date(date, chunk)
    @chunks_on_date[date] ||= {first_half_day: [], second_half_day: []}
    if chunk.first_half_day? || chunk.whole_day?
      @chunks_on_date[date][:first_half_day].push(chunk)
    end
    if chunk.second_half_day? || chunk.whole_day?
      @chunks_on_date[date][:second_half_day].push(chunk)
    end
  end

  def chunks_on_date_to_working_time(date, date_chunks)
    first_half_day = 0.5 * date_chunks_to_planned_working_time(date, date_chunks[:first_half_day])
    second_half_day = 0.5 * date_chunks_to_planned_working_time(date, date_chunks[:second_half_day])
    first_half_day + second_half_day
  end

  def date_chunks_to_planned_working_time(date, chunks)
    chunks.collect { |chunk| date_chunk_to_planned_working_time(date, chunk) }.max || 0
  end

  def date_chunk_to_planned_working_time(date, chunk)
    # date chunks (from absences) are calculated independent of the workload, cf. redmine #5596
    duration = CalculatePlannedWorkingTime.new(date.to_range, chunk.user, fulltime: true).total
    round(duration)
  end

  def ignore_exclusion_flag?
    !!@ignore_exclusion_flag
  end

  def round(duration)
    UberZeit.round(duration)
  end
end
