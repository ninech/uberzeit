class Summarize::User::Absences
  attr_reader :entries, :total

  def initialize(user, range, interval, start_from = nil)
    @range = range
    @time_sheet = user.current_time_sheet
    @interval = interval
    @start_from = start_from

    calculate
  end

  private

  def calculate
    @summarize_method = :summarize_absence_range
    summary
  end

  def summary
    @ranges = self.class.generate_ranges(@range, @interval, @start_from)
    @evaluator = {}
    @entries = @ranges.collect { |range| method(@summarize_method).call(range, @evaluator) }
  end

  def summarize_absence_range(range, evaluator)
    summary = {range: range}
    TimeType.absence.each_with_object(summary) do |time_type, hash|
      chunks = @time_sheet.find_chunks(range, time_type)
      chunks.ignore_exclusion_flag = true # include time types with exclusion flag in calculation (e.g. compensation)
      total_for_time_type = chunks.total
      evaluator[time_type.id] = (evaluator[time_type.id] || 0) + total_for_time_type
      hash[time_type.id] = total_for_time_type
    end
    summary
  end

  def self.generate_ranges(range, interval, start_from = nil)
    cursor = start_from || range.min
    ranges = []
    while cursor <= range.max
      range_at_cursor = cursor...cursor+interval
      ranges.push(range_at_cursor.intersect(range))
      cursor += interval
    end
    ranges
  end
end
