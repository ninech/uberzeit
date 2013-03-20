module AbsencesHelper

  def render_calendar_cell(day)
    absences = @absences[day.to_date.to_s]
    if absences
      css_class = "event-color#{color_index_of_array(absences)}"
    end

    if css_class
      [tooltips_for_day(day), {:class => css_class}]
    else
      [day.mday]
    end
  end

  def tooltips_for_day(day)
    content_tag(:span, day.mday, class: 'has-click-tip', title: tooltip_content_for_day(day))
  end

  def tooltip_content_for_day(day)
    absences = @absences[day.to_date.to_s]
    absences.map do |absence|
      edit_link = link_to('#', class: 'remote-reveal', :'data-reveal-id' => 'edit-absence-modal', :'data-reveal-url' => edit_time_sheet_absence_path(@time_sheet, absence.parent_id)) do
        "<i class='icon-edit event-color#{color_index_of_element(absence)}'> </i>".html_safe
      end
      delete_link = link_to(time_sheet_absence_path(@time_sheet, absence.parent_id), method: :delete) do
        "<i class='icon-remove-sign event-color#{color_index_of_element(absence)}'> </i>".html_safe
      end
      "#{edit_link} #{text_for_absence(absence)} #{delete_link}"
    end.join('<br />')
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

  def text_for_absence(absence)

    if absence.half_day_specific?
      time_range = case
                   when absence.whole_day?
                     t('.whole_day')
                   when absence.first_half_day?
                     t('.first_half_day')
                   when absence.second_half_day?
                     t('.second_half_day')
                   end
    else
      time_range = "#{l(absence.starts)} - #{l(absence.ends)}"
    end

    "#{time_range} #{absence.time_type.name}"
  end

end
