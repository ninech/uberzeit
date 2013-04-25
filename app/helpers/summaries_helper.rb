module SummariesHelper
  def format_work_days(duration)
    text = number_with_precision(duration.to_work_days, precision: 1, strip_insignificant_zeros: true)
    content_tag(:span, text, style: "color: #{color_for_duration(duration)}")
  end

  def format_hours(duration)
    "<span style='color: #{color_for_duration(duration)}'>#{display_in_hours(duration)}</span>".html_safe
  end

  def types_to_tooltip_table(hash)
    tooltip = ""

    hash.each_pair do |name, time|
      next if time == 0
      tooltip += ("<div class='tr'><div class='td'>#{name}</div><div class='td'>#{format_hours(time)}</div></div>").html_safe
    end

    unless tooltip.blank?
      tooltip = "<div class='tbl-tooltip'>#{tooltip}</div>"
    end

    tooltip
  end

  def label_for_month(date)
    I18n.l(date, format: t('summaries.formats.month'))
  end

  def label_for_range(range)
    starts = I18n.l(range.min, format: t('summaries.formats.date'))
    ends = I18n.l(range.max, format: t('summaries.formats.date'))
    [starts, ends].join(' - ')
  end

  def absences_only_half_day?(absences)
    absences.all? { |absence| absence.half_day? }
  end

  def first_half_day_absence(absences)
    absences.find { |absence| absence.first_half_day? }
  end

  def second_half_day_absence(absences)
    absences.find { |absence| absence.second_half_day? }
  end

  def whole_day_absence(absences)
    absences.find { |absence| absence.whole_day? }
  end

  def render_absences_cell(absences)
          # <% if absences.nil? %>
          #   <td colspan="2" class="full">&nbsp;</td>
          # <% else %>
          #   <% if absences_only_half_day?(absences) %>
          #     <% first_absence = first_half_day_absence(absences) %>
          #     <% if first_absence.nil? %>
          #       <td class="half">&nbsp;</td>
          #     <% else %>
          #       <td class="half event-bg<%=color_index_of_time_type(absences.first.time_type)%>"><%= icon_for_time_type(first_absence.time_type) %></td>
          #     <% end %>

          #     <% second_absence = second_half_day_absence(absences) %>
          #     <% if second_absence.nil? %>
          #       <td class="half">&nbsp;</td>
          #     <% else %>
          #       <td class="half event-bg<%=color_index_of_time_type(absences.first.time_type)%>"><%= icon_for_time_type(second_absence.time_type) %></td>
          #     <% end %>
          #   <% else %>
          #     <td colspan="2" class="not-empty full event-bg<%=color_index_of_time_type(absences.first.time_type)%>"><%= icon_for_time_type(absences.first.time_type) %></td>
          #   <% end %>
          # <% end %>
      if absences.nil?
        content_tag :td, '', colspan: 2, class: 'full'
      else
        if absences_only_half_day?(absences)
          first_absence = first_half_day_absence(absences)
          second_absence = second_half_day_absence(absences)

          content_tag :td, icon_for_time_type((first_absence||second_absence).time_type), colspan: 2, class: 'full'
        else
          full_absence = whole_day_absence(absences)
          content_tag :td, icon_for_time_type(full_absence.time_type), colspan: 2, class: 'full'
        end
      end
  end

end
