module AbsencesHelper

  def render_calendar_cell(day)
    absences =       @absences[day.to_date.to_s]
    public_holiday = @public_holidays[day.to_date.to_s]
    is_work_day =    UberZeit.is_weekday_a_workday?(day)

    cls = []
    cls << 'non-work-day' unless is_work_day
    cls << 'public-holiday' if public_holiday

    content = if absences
                content_tag :div, class: 'event-container' do
                  render_absences(absences, day.mday).html_safe
                end
              else
                day.mday
              end

    tooltip = if absences
                tooltip_content_for_absence(day)
              elsif public_holiday
                tooltip_content_for_public_holiday(day)
              else
                ''
              end

    cls << 'has-click-tip' unless tooltip.blank?

    unless absences or public_holiday
      cls << "has-reveal remote-reveal"
    end

    [content, {:class => cls.join(' '), :'data-tooltip' => tooltip, :'data-reveal-id' => 'add-absence-modal', :'data-reveal-url' => new_time_sheet_absence_path(@time_sheet, date: day)}]
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

  def tooltip_content_for_absence(day)
    absences = @absences[day.to_date.to_s]
    render(partial: 'shared/absences_tooltip', locals: { absences: absences }).to_s
  end

  def tooltip_content_for_public_holiday(day)
    public_holiday = @public_holidays[day.to_date.to_s]
    render(partial: 'shared/public_holiday_tooltip', locals: { public_holiday: public_holiday }).to_s
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
    absence_object = absence.parent

    range = if absence_object.recurring?
              (absence.starts..absence.starts+absence_object.duration).to_date_range
            else
              absence_object.range
            end

    if range.min == range.max
      l(range.min)
    else
      "#{l(range.min)} - #{l(range.max)}"
    end
  end

  def absence_recurring(absence)
    if absence.recurring_schedule.active?
      if absence.recurring_schedule.ends_on_date?
        t('.recurring_interval_until_date', { interval: absence.recurring_schedule.weekly_repeat_interval, ends: l(absence.recurring_schedule.end_date) })
      else
        t('.recurring_interval_endless', { interval: absence.recurring_schedule.weekly_repeat_interval })
      end
    end
  end
end
