module TimeSheetsHelper
  def worktime_for_day(day)
    worktime = @time_sheet.work(day)
    if @timer && Date.parse(@timer.start_date) == day
      worktime += @timer.duration
    end

    format_duration(worktime)
  end

  def worktime_for_week(week)
    worktime = @time_sheet.work(@week)
    if @timer && @week.include?(@timer.start_date.to_date)
      worktime += @timer.duration
    end

    format_duration(worktime)
  end

  def format_duration(duration)
    hours = duration.to_hours.to_i
    minutes = (duration - hours * 1.hour).to_minutes.to_i
    "%02i:%02i" % [hours, minutes]
  end

end
