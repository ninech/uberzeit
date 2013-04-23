class SummarizeUser
  def initialize(user, year_or_range, interval, start_from = nil)
    if year_or_range.kind_of?(Range)
      @range = year_or_range
    else
      @range = UberZeit.year_as_range(year_or_range)
    end
    @time_sheet = user.current_time_sheet
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
    @ranges = self.class.generate_ranges(@range, @interval, @start_from)
    @rows, @total = summarize

    return @rows, @total
  end

  def summarize
    evaluator = {}
    rows = @ranges.collect { |range| method(@summarize_method).call(range, evaluator) }
    return rows, evaluator
  end

  def summarize_work_range(range, evaluator)
    planned                   = @time_sheet.planned_work(range)
    effective_worked          = @time_sheet.total(range, TimeType.work)
    effective_worked_by_type  = TimeType.work.each_with_object({}) { |time_type,hash| hash[time_type.name] = @time_sheet.total(range, time_type) }
    absent                    = @time_sheet.total(range, TimeType.absence)
    absent_by_type            = TimeType.absence.each_with_object({}) { |time_type,hash| hash[time_type.name] = @time_sheet.total(range, time_type) }
    time_bonus                = @time_sheet.bonus(range, TimeType.work)
    overtime                  = @time_sheet.overtime(range)

    evaluator[:sum] = (evaluator[:sum] || 0) + overtime

    {range: range, planned: planned, effective_worked: effective_worked, absent: absent, time_bonus: time_bonus, overtime: overtime, sum: evaluator[:sum], effective_worked_by_type: effective_worked_by_type, absent_by_type: absent_by_type}
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
