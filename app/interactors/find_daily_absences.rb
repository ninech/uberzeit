class FindDailyAbsences
  attr_reader :users, :range

  def initialize(users, date_or_range)
    @users = [users].flatten
    @range = date_or_range.to_range.to_date_range
  end

  def result
    @result ||= find_absences
  end

  private

  def find_absences
    absences_to_chunks_per_day(users)
  end

  def absences_to_chunks_per_day(users)
    chunks = {}
    users.each do |ts|
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
