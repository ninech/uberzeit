module AbsencesHelper

  def render_calendar_cell(day)
    absences = @absences[day.to_date.to_s]

    if absences
      css_class = "has-absences event-color#{color_index_of_array(absences)}"
      [tooltips_for_day(day), {:class => css_class}]
    else
      [day.mday]
    end
  end

  def tooltips_for_day(day)
    content_tag(:span, day.mday, class: 'has-click-tip', data: { tooltip: tooltip_content_for_day(day) })
  end

  def tooltip_content_for_day(day)
    absences = @absences[day.to_date.to_s]
    render(partial: 'absences/absences_tooltip', locals: { absences: absences }).to_s

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

  # def text_for_absence(absence)

  #   if absence.half_day_specific?
  #     time_range = case
  #                  when absence.whole_day?
  #                    t('.whole_day')
  #                  when absence.first_half_day?
  #                    t('.first_half_day')
  #                  when absence.second_half_day?
  #                    t('.second_half_day')
  #                  end
  #   else
  #     time_range = "#{l(absence.starts)} - #{l(absence.ends)}"
  #   end

  #   "#{time_range} #{absence.time_type.name}"
  # end

end
