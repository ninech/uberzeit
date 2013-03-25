class SummaryController < ApplicationController
  load_and_authorize_resource :time_sheet, parent: false

  def work_summary
    @year = (params[:year] || Date.current.year).to_i
    summarize_time_sheet = SummarizeTimeSheet.new(@time_sheet, @year, 1.month)

    @rows, @total = summarize_time_sheet.work

    @rows.each do |row|
      start_date = row[:range].min
      month = start_date.month

      row[:month] = month
      row[:name] = start_date.strftime('%B')
      row[:link] = url_for(action: 'work_summary_per_month', year: @year, month: month, type: @type)

      if @year == Date.current.year && month > Date.current.month
        row[:hide] = true
      end
    end
  end

  def work_summary_per_month
    @year = params[:year].to_i
    @month = params[:month].to_i
    range = range_for_month(@year, @month)
    summarize_time_sheet = SummarizeTimeSheet.new(@time_sheet, range, 1.week, range.min.monday) # start with monday!

    @rows, @total = summarize_time_sheet.work

    @rows.each do |row|
      row[:name] = [row[:range].min.strftime('%e. %a.'), row[:range].max.strftime('%e. %a.')].join(' - ')
      row[:link] = url_for(controller: :time_sheets, action: :show, id: @time_sheet, date: row[:range].min)
    end
  end

  def absence_summary
    @year = (params[:year] || Date.current.year).to_i
    summarize_time_sheet = SummarizeTimeSheet.new(@time_sheet, @year, 1.month)

    @rows, @total = summarize_time_sheet.absence

    @rows.each do |row|
      start_date = row[:range].min
      month = start_date.month

      row[:month] = month
      row[:name] = start_date.strftime('%B')
      row[:link] = url_for(action: 'absence_summary_per_month', year: @year, month: month, type: @type)
    end

    vacation_id = TimeType.vacation.first.id
    vacation_remaining = @time_sheet.user.vacation_available(@year) - @total[vacation_id]
    @remaining = {vacation_id => vacation_remaining}
  end

  def absence_summary_per_month
    @year = params[:year].to_i
    @month = params[:month].to_i
    range = range_for_month(@year, @month)
    summarize_time_sheet = SummarizeTimeSheet.new(@time_sheet, range, 1.week, range.min.monday) # start with monday!

    @rows, @total = summarize_time_sheet.absence

    @rows.each do |row|
      row[:name] = [row[:range].min.strftime('%e. %a.'), row[:range].max.strftime('%e. %a.')].join(' - ')
      row[:link] = url_for(controller: :time_sheets, action: :show, id: @time_sheet, date: row[:range].min)
    end
  end

  private

  def range_for_month(year, month)
    first_day_of_month = Date.new(year, month)
    last_day_of_month = first_day_of_month.end_of_month
    first_day_of_month..last_day_of_month
  end
end
