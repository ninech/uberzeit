module AbsencesHelper

  def render_calendar_cell(day)
    absences = @absences[day.to_date.to_s]
    public_holiday = @public_holidays[day.to_date.to_s]

    if absences
      css_class = "has-absences event-color#{suffix_for_daypart(absences.first)}#{color_index_of_array(absences)}"
      [tooltips_for_day(day, :tooltip_content_for_absence), {:class => css_class}]
    elsif public_holiday
      css_class = "has-absences public-holiday#{suffix_for_daypart(public_holiday)}"
      [tooltips_for_day(day, :tooltip_content_for_public_holiday), {:class => css_class}]
    else
      [day.mday]
    end
  end

  def suffix_for_daypart(absence)
    if absence.first_half_day?
      "-first-half"
    elsif absence.second_half_day?
      "-second-half"
    else
      ""
    end
  end

  def tooltips_for_day(day, content_method)
    content_tag(:span, day.mday, class: 'has-click-tip', data: { tooltip: method(content_method).call(day) })
  end

  def tooltip_content_for_absence(day)
    absences = @absences[day.to_date.to_s]
    render(partial: 'absences/absences_tooltip', locals: { absences: absences }).to_s
  end

  def tooltip_content_for_public_holiday(day)
    public_holiday = @public_holidays[day.to_date.to_s]
    render(partial: 'absences/public_holiday_tooltip', locals: { public_holiday: public_holiday }).to_s
  end

  def color_index_of_array(absences)
    absences.each do |absence|
      color_index = color_index_of_element(absence)
      if color_index
        return color_index
      end
    end
  end

  def color_index_of_element(absence)
    @time_types.index { |time_type| time_type == absence.time_type }
  end

  def absence_period(absence)
    if absence.half_day_specific?
      case
      when absence.first_half_day?
        t('.first_half_day')
      when absence.second_half_day?
        t('.second_half_day')
      else
        nil
      end
    end
  end

  def absence_date_range(absence)
    unless absence.starts == absence.ends
      "#{l(absence.starts.to_date)} - #{l(absence.ends.to_date)}"
    else
      l(absence.starts.to_date)
    end
  end
end
