class TimeSheetsController < ApplicationController
  load_and_authorize_resource :time_sheet

  def show
    unless params[:date].nil?
      @day = Time.zone.parse(params[:date]).to_date
    end

    @day ||= Time.zone.today

    @week     = @day.at_beginning_of_week..@day.at_end_of_week
    @weekdays = @week.to_a
    @year     = @week.min.year
    @previous_week_day = (@week.min - 1).at_beginning_of_week
    @next_week_day = @week.max + 1

    @time_chunks = @time_sheet.find_chunks(@day)

    # stuff for add form in modal
    @time_entry = TimeEntry.new
    if params[:date]
      @time_entry.start_date = params[:date]
    end
    @time_types = TimeType.find_all_by_is_work(true)

    @timer = @time_sheet.timer
    unless @timer.nil?
      @timer_active = @timer.start_date == (params[:date] || Time.current.to_date.to_s(:db))
    end
  end

  def stop_timer
    @time_sheet.timer.stop

    render json: {}
  end

  def summary
    @year = (params[:year] || Date.current.year).to_i

    @summary_title = t('.total_working_time_in_hours')
    year_range = UberZeit.year_as_range(@year)

    ranges = generate_ranges(year_range, 1.month)
    @summary = summary_for_ranges(ranges, :work_summary).collect do |summary|
      start_date = summary[:range].min
      month = start_date.month

      summary[:month] = month
      summary[:name] = start_date.strftime('%B')
      summary[:link] = url_for(action: 'sub_summary_rows', year: @year, month: month)

      if @year == Date.current.year && month > Date.current.month
        summary[:hide] = true
      end

      summary[:remote] = true
      summary
    end
  end

  def sub_summary_rows
    @year = params[:year].to_i
    @month = params[:month].to_i

    first_day_of_month = Date.new(@year, @month)
    last_day_of_month = first_day_of_month.end_of_month

    range = first_day_of_month..last_day_of_month

    ranges = generate_ranges(range, 1.week, first_day_of_month.monday) # start with monday!
    @summary = summary_for_ranges(ranges, :work_summary).collect do |summary|
      summary[:name] = [summary[:range].min.strftime('%e. %a.'), summary[:range].max.strftime('%e. %a.')].join(' - ')
      summary[:link] = url_for(action: :show, date: summary[:range].min)
      summary
    end

    @summary_title = first_day_of_month.strftime('%B %Y')
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
    evaluator = {sum: 0}
    ranges.collect do |range|
      method(summary_method).call(range, evaluator)
    end
  end

  def work_summary(range, evaluator)
    planned = @time_sheet.planned_work(range)
    worked = @time_sheet.work(range)
    overtime = @time_sheet.overtime(range)
    by_type = {}

    TimeType.all.each do |type|
      by_type[type.name] = @time_sheet.total(range, type)
    end

    evaluator[:sum] += overtime

    { range: range, planned: planned, worked: worked, overtime: overtime, sum: evaluator[:sum], by_type: by_type }
  end
end
