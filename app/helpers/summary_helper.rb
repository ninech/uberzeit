module SummaryHelper
  def format_work_days(duration)
    color = if duration == 0
              'gray'
            else
              ''
            end

    content_tag(:span, number_with_precision(duration.to_work_days, precision: 1), style: "color: #{color}")
  end

  def format_hours(duration)
    color = if duration == 0
            'gray'
          elsif duration < 0
            'tomato'
          else
            ''
          end

    content_tag(:span, number_with_precision(duration.to_hours, precision: 2), style: "color: #{color}")
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
end
