module AbsencesHelper

  def render_calendar_cell(day)
    absences =       @absences[day.to_date]
    public_holiday = @public_holidays[day.to_date]
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

    unless absences || public_holiday || !can?(:manage, Absence)
      cls << "has-reveal remote-reveal"
    end

    options = {:class => cls.join(' ')}
    unless tooltip.blank?
      options.merge! :'data-tooltip' => tooltip
    end
    if can? :manage, Absence
      options.merge! :'data-reveal-id' => 'absence-modal', :'data-reveal-url' => new_user_absence_path(@user, date: day)
    end
    if params[:add_absence_for_date] == day.to_s
      options.merge! :'data-reveal-on-load' => ''
    end

    [content, options]
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
    absences = @absences[day.to_date]
    render(partial: 'shared/absences_tooltip', locals: { absences: absences, day: day, user: @user }).to_s
  end

  def tooltip_content_for_public_holiday(day)
    public_holiday = @public_holidays[day.to_date]
    render(partial: 'shared/public_holiday_tooltip', locals: { public_holiday: public_holiday }).to_s
  end

  def absence_period(absence)
    unless absence.whole_day?
      case
      when absence.first_half_day?
        t('first_half_day')
      when absence.second_half_day?
        t('second_half_day')
      else
        nil
      end
    end
  end

  def absence_date_range(absence, occurrence_date)
    range = if absence.recurring?
              absence.occurrences.find { |occurrence| occurrence.intersects_with_duration?(occurrence_date.to_range) }
            else
              absence.range
            end

    if range.min == range.max
      l(range.min)
    else
      "#{l(range.min)} - #{l(range.max)}"
    end
  end

  def absence_recurring(absence)
    if absence.schedule.active?
      t('.recurring_interval_until_date', { interval: absence.schedule.weekly_repeat_interval, ends: l(absence.schedule.ends_date) })
    end
  end

  def other_team_members(user)
    team_members_by_teams(user.teams) - [user]
  end

  def team_members_by_teams(teams)
    User.joins(:teams)
        .where(memberships: {team_id: teams})
        .uniq
        .to_a
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
