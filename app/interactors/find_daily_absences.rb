class FindDailyAbsences
  attr_reader :time_sheets, :range

  def initialize(time_sheets, date_or_range)
    @time_sheets = time_sheets
    @range = date_or_range.to_range.to_date_range
  end

  def result
    @result ||= find_absences
  end

  private

  def find_absences
    absences_to_chunks_per_day(time_sheets)
  end

  def absences_to_chunks_per_day(time_sheets)
    chunks = {}
    time_sheets.each do |ts|
      daily_time_chunks_for(ts.absences) do |date, chunk|
        chunks[date] ||= []
        chunks[date] << chunk
      end
    end
    chunks
  end

  def daily_time_chunks_for(entries)
    time_chunks_finder = FindTimeChunks.new(entries)
    time_chunks_finder.in_range(range).each do |chunk|
      chunk.range.to_date_range.each do |date|
        yield(date, chunk)
      end
    end
  end
end
