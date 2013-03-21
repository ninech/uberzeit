module TimeSheetsHelper
  def worktime_for_day(day)
    worktime = @time_sheet.total(day, TimeType.work)
    if @timer && Date.parse(@timer.start_date) == day
      worktime += @timer.duration
    end

    l Time.at(worktime)
  end

  def worktime_for_week(week)
    worktime = @time_sheet.total(@week, TimeType.work)
    if @timer && @week.include?(@timer.start_date.to_date)
      worktime += @timer.duration
    end

    l Time.at(worktime)
  end
end
