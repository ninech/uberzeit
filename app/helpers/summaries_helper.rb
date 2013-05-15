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

  def render_absences(absences, text = nil)
    return '' if absences.nil?
    absences.collect { |absence| render_absence(absence, text) }.join
  end

  def render_absence(absence, text = nil)
    time_type = absence.time_type

    content_tag :div, class: "event-bg#{suffix_for_daypart(absence)}#{color_index_of_time_type(time_type)}" do # overlay div event bg
      css_class = if absence.first_half_day?
                    'top-left'
                  elsif absence.second_half_day?
                    'bottom-right'
                  else
                    ''
                  end

      content_tag :div, class: css_class do # table div icon
        if text
          content_tag :div, text # cell div
        else
          content_tag :div do # cell div
            icon_for_time_type(time_type)
          end
        end
      end
    end
  end

end
