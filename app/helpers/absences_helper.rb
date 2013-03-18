module AbsencesHelper

  def render_calendar_cell(day)
    absence = @absences[day.to_date.to_s]
    if absence
      color_index = @time_types.index { |time_type| time_type == absence.time_type }
      css_class = "event-color#{color_index}"
    end

    if css_class
      [tooltips_for_day(day), {:class => css_class}]
    else
      [day.mday]
    end
  end

  def tooltips_for_day(day)
    content_tag(:span, day.mday, class: 'has-tip tip-bottom', title: '<i>Blubb</i>', :'data-tooltip' => true)
  end

  def tooltip_content_for_day(day)

  end

end
