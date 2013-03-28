class TimeChunkCollection

  attr_reader :chunks

  def initialize(chunks = [])
    @chunks = chunks
  end

  def total
    total_for_time_chunks + total_for_date_chunks
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

  def total_for_time_chunks
    time_chunks.inject(0.0) do |sum,chunk|
      sum + chunk.effective_duration
    end
  end

  # make sure we only count chunks on the same date once
  def total_for_date_chunks
    @chunks_on_date = {}

    date_chunks.each do |chunk|
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
    chunks.collect { |chunk| chunk_to_planned_working_time(date, chunk) }.max || 0
  end

  def chunk_to_planned_working_time(date, chunk)
    user = chunk.time_sheet.user
    calculation_factor = chunk.time_type.calculation_factor
    calculation_factor * CalculatePlannedWorkingTime.new(user, date.to_range, fulltime: true).total
  end
end
