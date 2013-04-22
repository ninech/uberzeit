class SummaryController < ApplicationController
  include SummaryHelper

  load_and_authorize_resource :time_sheet, parent: false

  def work_summary
    @year = (params[:year] || Date.current.year).to_i
    summarize_time_sheet = SummarizeTimeSheet.new(@time_sheet, @year, 1.month)

    @rows, @total = summarize_time_sheet.work

    @rows.each do |row|
      start_date = row[:range].min
      month = start_date.month

      row[:month] = month
      row[:name] = label_for_month(start_date)
      row[:link] = url_for(action: 'work_summary_per_month', year: @year, month: month, type: @type)

      if @year == Date.current.year && month > Date.current.month
        row[:hide] = true
      end
    end
  end

  def work_summary_per_month
    @year = params[:year].to_i
    @month = params[:month].to_i
    range = UberZeit.month_as_range(@year, @month)
    summarize_time_sheet = SummarizeTimeSheet.new(@time_sheet, range, 1.week, range.min.monday) # start with monday!

    @rows, @total = summarize_time_sheet.work

    @rows.each do |row|
      row[:name] = label_for_range(row[:range])
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
      row[:name] = label_for_month(start_date)
      row[:link] = url_for(action: 'absence_summary_per_month', year: @year, month: month, type: @type)
    end

    @remaining = {}
    unless TimeType.vacation.first.nil?
      vacation_id = TimeType.vacation.first.id
      vacation_remaining = @time_sheet.total_reedemable_vacation(@year) - @total[vacation_id]
      @remaining[vacation_id] = vacation_remaining
    end
  end

  def absence_summary_per_month
    @year = params[:year].to_i
    @month = params[:month].to_i
    range = UberZeit.month_as_range(@year, @month)
    summarize_time_sheet = SummarizeTimeSheet.new(@time_sheet, range, 1.week, range.min.monday) # start with monday!

    @rows, @total = summarize_time_sheet.absence

    @rows.each do |row|
      row[:name] = label_for_range(row[:range])
      row[:link] = url_for(controller: :time_sheets, action: :show, id: @time_sheet, date: row[:range].min)
    end
  end

end
