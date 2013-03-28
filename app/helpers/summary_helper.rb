module SummaryHelper
  def format_work_days(duration)
    text = number_with_precision(duration.to_work_days, precision: 1, strip_insignificant_zeros: true)
    content_tag(:span, text, style: "color: #{color_for_duration(duration)}")
  end

  def format_hours(duration)
    content_tag(:span, number_with_precision(duration.to_hours, precision: 2), style: "color: #{color_for_duration(duration)}")
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
