class SummarizeTimeSheet
  def initialize(time_sheet, year_or_range, interval, start_from = nil)
    @time_sheet = time_sheet
    if year_or_range.kind_of?(Range)
      @range = year_or_range
    else
      @range = UberZeit.year_as_range(year_or_range)
    end
    @interval = interval
    @start_from = start_from
  end

  def work
    @summarize_method = :summarize_work_range
    summary
  end

  def absence
    @summarize_method = :summarize_absence_range
    summary
  end

  private

  def summary
    @ranges = SummarizeTimeSheet.generate_ranges(@range, @interval, @start_from)
    @rows, @total = summarize
    return @rows, @total
  end

  def summarize
    evaluator = {}
    rows = @ranges.collect { |range| method(@summarize_method).call(range, evaluator) }
    return rows, evaluator
  end

  def summarize_work_range(range, evaluator)
    planned   = @time_sheet.planned_work(range)
    worked    = @time_sheet.work(range)
    overtime  = @time_sheet.overtime(range)
    by_type   = TimeType.all.each_with_object({}) { |time_type,hash| hash[time_type.name] = @time_sheet.total(range, time_type) }

    evaluator[:sum] = (evaluator[:sum] || 0) + overtime

    {range: range, planned: planned, worked: worked, overtime: overtime, sum: evaluator[:sum], by_type: by_type}
  end

  def summarize_absence_range(range, evaluator)
    summary = {range: range}
    TimeType.absence.each_with_object(summary) do |time_type, hash|
      total_for_time_type = @time_sheet.total(range, time_type)
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
