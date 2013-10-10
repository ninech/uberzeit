module ReportsHelper
  include ActivitiesHelper

  def format_work_days(duration)
    text = number_with_precision(duration, precision: 1, strip_insignificant_zeros: true)
    content_tag(:span, text + ' d', style: "color: #{color_for_duration(duration)}")
  end

  def format_hours(duration)
    content_tag(:span, display_in_hours(duration), style: "color: #{color_for_duration(duration)}")
  end

  def hash_to_tooltip_table(hash)
    tooltip = ""

    hash.each_pair do |key, value|
      key, value = yield(key, value) if block_given?
      next if key.nil? or value.nil?
      tooltip += ("<div class='tr'><div class='td'>#{key}</div><div class='td'>#{value}</div></div>").html_safe
    end

    tooltip = "<div class='tbl-tooltip'>#{tooltip}</div>" unless tooltip.blank?
  end

  def time_per_time_type_to_tooltip_table(time_per_time_type)
    hash_to_tooltip_table(time_per_time_type) do |time_type, duration|
      duration == 0 ? nil : [time_type, format_duration_by_time_type(duration, time_type)]
    end
  end

  def time_per_adjustment_to_tooltip_table(time_per_adjustment_hash)
    hash_to_tooltip_table(time_per_adjustment_hash) do |adjustment, duration|
      duration == 0 ? nil : [adjustment, format_duration_by_time_type(duration, adjustment.time_type)]
    end
  end

  def format_duration_by_time_type(duration, time_type)
    time_type.is_absence? ? format_work_days(duration.to_work_days) : format_hours(duration)
  end

  def label_for_month(date)
    I18n.l(date, format: t('reports.formats.month'))
  end

  def label_for_range(range)
    starts = I18n.l(range.min, format: t('reports.formats.date'))
    ends = I18n.l(range.max, format: t('reports.formats.date'))
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

  def awesome_hours_and_minutes(duration)
    hours = awesome_tag("%i" % duration.to_hours)
    minutes = awesome_tag("%i" % (duration % 1.hour).to_minutes)

    t('.formats.hours_and_minutes_html' , hours: hours, minutes: minutes)
  end

  def awesome_work_days(duration)
    work_days = awesome_tag("%g" % duration.to_work_days)
    t('.formats.work_days_html', work_days: work_days)
  end

  def awesome_tag(text)
    data = {}
    if text =~ /^[-+]?[0-9]*\.?[0-9]+%?$/
      data[:'count-from'] = 0
      data[:'count-to'] = text
    end
    content_tag(:span, text, class: 'awesome', data: data)
  end

  def given_name_with_one_lettered_last_name(user)
    [user.given_name, "#{user.name.chars.first}."].compact.join(' ')
  end
end
