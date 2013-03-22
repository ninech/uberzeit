class SummaryController < ApplicationController
  load_and_authorize_resource :time_sheet, parent: false

  def work_summary
    @year = (params[:year] || Date.current.year).to_i
    @ranges = generate_ranges(UberZeit.year_as_range(@year), 1.month)

    @summary, @evaluator = summary_for_ranges(@ranges, :work_summary_in_range)

    @summary.each do |summary|
      start_date = summary[:range].min
      month = start_date.month

      summary[:month] = month
      summary[:name] = start_date.strftime('%B')
      summary[:link] = url_for(action: 'work_summary_per_month', year: @year, month: month, type: @type)

      if @year == Date.current.year && month > Date.current.month
        summary[:hide] = true
      end

      summary
    end
  end

  def absence_summary
    @year = (params[:year] || Date.current.year).to_i
    @ranges = generate_ranges(UberZeit.year_as_range(@year), 1.month)

    @summary, @evaluator = summary_for_ranges(@ranges, :absence_summary_in_range)

    @summary.each do |summary|
      start_date = summary[:range].min
      month = start_date.month

      summary[:month] = month
      summary[:name] = start_date.strftime('%B')
      summary[:link] = url_for(action: 'absence_summary_per_month', year: @year, month: month, type: @type)

      summary
    end
  end

  def work_summary_per_month
    @year = params[:year].to_i
    @month = params[:month].to_i

    first_day_of_month = Date.new(@year, @month)
    last_day_of_month = first_day_of_month.end_of_month

    range = first_day_of_month..last_day_of_month
    ranges = generate_ranges(range, 1.week, first_day_of_month.monday) # start with monday!

    @summary, @evaluator = summary_for_ranges(ranges, :work_summary_in_range)

    @summary.each do |summary|
      summary[:name] = [summary[:range].min.strftime('%e. %a.'), summary[:range].max.strftime('%e. %a.')].join(' - ')
      summary[:link] = url_for(controller: :time_sheets, action: :show, id: @time_sheet, date: summary[:range].min)
      summary
    end
  end

  def absence_summary_per_month
    @year = params[:year].to_i
    @month = params[:month].to_i

    first_day_of_month = Date.new(@year, @month)
    last_day_of_month = first_day_of_month.end_of_month

    range = first_day_of_month..last_day_of_month
    ranges = generate_ranges(range, 1.week, first_day_of_month.monday) # start with monday!

    @summary, @evaluator = summary_for_ranges(ranges, :absence_summary_in_range)

    @summary.each do |summary|
      summary[:name] = [summary[:range].min.strftime('%e. %a.'), summary[:range].max.strftime('%e. %a.')].join(' - ')
      summary[:link] = url_for(controller: :time_sheets, action: :show, id: @time_sheet, date: summary[:range].min)
      summary
    end
  end

  private

  def generate_ranges(range, interval, start_from = nil)
    cursor = start_from || range.min
    ranges = []
    while cursor <= range.max
      range_at_cursor = cursor...cursor+interval
      ranges.push(range_at_cursor.intersect(range))
      cursor += interval
    end
    ranges
  end

  def summary_for_ranges(ranges, summary_method)
    evaluator = {}
    summary = ranges.collect { |range| method(summary_method).call(range, evaluator) }
    return summary, evaluator
  end

  def work_summary_in_range(range, evaluator)
    planned = @time_sheet.planned_work(range)
    worked = @time_sheet.work(range)
    overtime = @time_sheet.overtime(range)
    by_type = {}

    TimeType.all.each do |type|
      by_type[type.name] = @time_sheet.total(range, type)
    end

    evaluator[:sum] = (evaluator[:sum] || 0) + overtime

    {range: range, planned: planned, worked: worked, overtime: overtime, sum: evaluator[:sum], by_type: by_type}
  end

  def absence_summary_in_range(range, evaluator)
    summary = {range: range}

    TimeType.absence.each do |time_type|
      total_for_time_type = @time_sheet.total(range, time_type)

      evaluator[time_type.id] = (evaluator[time_type.id] || 0) + total_for_time_type

      summary[time_type.id] = total_for_time_type
    end

    summary
  end
end
