module AbsencesHelper

  def render_calendar_cell(day)
    absence = @absences[day.to_date.to_s]
    if absence
      color_index = @time_types.index { |time_type| time_type == absence }
      css_class = "event-color#{color_index}"
    end

    if css_class
      [day.mday, {:class => css_class}]
    else
      [day.mday]
    end
  end

end
