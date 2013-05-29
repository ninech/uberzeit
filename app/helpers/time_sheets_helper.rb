module TimeSheetsHelper
  def formatted_worktime_for_day(day)
    worktime = worktime_for_range(day)
    format_duration(worktime)
  end

  def formatted_worktime_for_range(range)
    worktime = worktime_for_range(range)
    format_duration(worktime)
  end

  def formatted_overtime_for_range(range)
    overtime = overtime_for_range(range)
    format_duration(overtime)
  end

  def format_duration(duration)
    content_tag(:span, display_in_hours(duration), style: "color: #{color_for_duration(duration)}")
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
    time_type.bonus_factor == 0.0
  end

  def time_type_bonus_percentage(time_type)
    bonus_percent = time_type.bonus_factor * 100.0
    "%s%%" % number_with_precision(bonus_percent, precision: 2, strip_insignificant_zeros: true)
  end

  def worktime_for_range(date_or_range)
    @time_sheet.work(date_or_range) + @time_sheet.duration_of_timers(date_or_range)
  end

  def overtime_for_range(date_or_range)
    @time_sheet.overtime(date_or_range) + @time_sheet.duration_of_timers(date_or_range)
  end

  def running_timer_dates(timers)
    if timers
      links = timers.map do |timer|
        link_to l(timer.start_time, format: :weekday), show_date_time_sheet_path(@time_sheet, date: timer.start_date)
      end
      links.to_sentence.html_safe
    end
  end
end
