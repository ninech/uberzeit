module AbsencesHelper

  def render_calendar_cell(day)
    absences = @absences[day.to_date.to_s]
    public_holiday = @public_holidays[day.to_date.to_s]


    if absences
      css_class = "has-absences event-bg#{suffix_for_daypart(absences.first)}#{color_index_of_array(absences)}"
      [tooltips_for_day(day, :tooltip_content_for_absence), {:class => css_class}]
    elsif public_holiday
      css_class = "has-absences public-holiday-bg#{suffix_for_daypart(public_holiday)}"
      [tooltips_for_day(day, :tooltip_content_for_public_holiday), {:class => css_class}]
    else
      css_class = "not-a-workday" unless UberZeit.is_weekday_a_workday?(day)
      [day.mday, {:class => css_class}]
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
