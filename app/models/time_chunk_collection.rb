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
      sum + chunk.duration * chunk.time_type.calculation_factor
    end
  end

  # make sure we only count chunks on the same date once
  def total_for_date_chunks
    @dates = {}

    date_chunks.each do |chunk|
      date_range = chunk.range.to_date_range
      date_range.each { |date| occupy(date, chunk) }
    end

    @dates.inject(0.0) do |sum,(date,data)|
      sum + translate_part_of_day_to_planned_working_time(date, data)
    end
  end

  def occupy(date, chunk)
    @dates[date] ||= {first_half_day: false, second_half_day: false, chunks: []}
    @dates[date][:first_half_day] ||= chunk.first_half_day? || chunk.whole_day?
    @dates[date][:second_half_day] ||= chunk.second_half_day? || chunk.whole_day?
    @dates[date][:chunks].push(chunk)
  end

  def translate_part_of_day_to_planned_working_time(date, data)
    coefficient = if data[:first_half_day] && data[:second_half_day]
                    1
                  else
                    0.5
                  end

    calculation_factor = average_calculation_factor(data[:chunks])
    coefficient * calculation_factor * CalculatePlannedWorkingTime.new(data[:chunks].first.time_sheet.user, date.to_range, fulltime: true).total
  end

  def average_calculation_factor(chunks)
    chunks.inject(0.0) { |sum,chunk| sum + chunk.time_type.calculation_factor } / chunks.size
  end
end
