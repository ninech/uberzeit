module TimeSheetsHelper
  def worktime_for_day(day)
    worktime = work_for_range(day)
    format_duration(worktime)
  end

  def worktime_for_week(week)
    worktime = work_for_range(week)
    format_duration(worktime)
  end

  def overtime_for_week(week)
    overtime = overtime_for_range(week)
    format_duration(overtime)
  end

  def format_duration(duration)
    content_tag(:span, hour_string(duration), style: "color: #{color_for_duration(duration)}")
  end

  def hour_string(duration)
    hours = duration.to_hours.to_i
    minutes = (duration - hours * 1.hour).to_minutes.ceil
    is_negative = hours < 0

    if is_negative
      "-%02i:%02i" % [hours.abs, minutes.abs]
    else
      "%02i:%02i" % [hours, minutes]
    end
  end

  def part_of_day(absence)
    if absence.whole_day?
      t('.whole_day')
    else
      case
      when absence.first_half_day?
        t('.first_half_day')
      when absence.second_half_day?
        t('.second_half_day')
      else
      end
    end
  end

  def standard_calculation?(time_type)
    time_type.calculation_factor == 1.0
  end

  def time_type_calculation_percentage(time_type)
    calculation_percent = time_type.calculation_factor * 100.0
    "%s%%" % number_with_precision(calculation_percent, precision: 2, strip_insignificant_zeros: true)
  end

  private

  def work_for_range(date_or_range)
    @time_sheet.work(date_or_range) + timer_duration(date_or_range)
  end

  def overtime_for_range(date_or_range)
    @time_sheet.overtime(date_or_range) + timer_duration(date_or_range)
  end

  def timer_duration(date_or_range)
    range = date_or_range.to_range.to_date_range
    if @timer && range.include?(@timer.start_date.to_date)
      # round down to full minutes to match the javascript timer duration
      timer_duration = @timer.duration.to_minutes.floor * 1.minute
      [timer_duration,0].max
    else
      0
    end
  end

  def running_timer_dates(timers)
    if timers
      links = timers.map { |x| "<a href=\"#{url_for(action: :show, date: x.start_date)}\">#{l x.start_time, format: '%d.%m.%Y'}</a>"}
      links.join(', ')
    end
  end
end
