module ApplicationHelper
  include TimeSheetsHelper

  def nav_link(name, link, match_controllers)
    if match_controllers.map(&:to_sym).include? controller.controller_name.to_sym
      classes = 'active'
    end
    link_to name, link, class: classes
  end

  def has_top_buttons?
    return false if @exception
    lookup_context.template_exists? 'top_buttons', controller.controller_name, true
  end

  def icon(*icon_classes)
    classes = icon_classes.map { |klass| "icon-#{klass}" }.join(' ')
    content_tag(:i, '', :class => classes)
  end

  def pickadate_js_localization
    I18n.t('js.pickadate').to_json.html_safe
  end

  def show_manage_link_in_navigation?
    can?(:manage, TimeType) || can?(:manage, Employment) || can?(:manage, PublicHoliday)
  end

  def color_for_duration(duration)
    if duration == 0
      'gray'
    elsif duration < 0
      'tomato'
    else
      ''
    end
  end

  def color_index_of_array(array)
    array.each do |element|
      color_index = color_index_of_element(element)
      if color_index
        return color_index
      end
    end
    return 0
  end

  def color_index_of_element(element)
    color_index_of_time_type(element.time_type)
  end

  def color_index_of_time_type(time_type)
    time_type.color_index
  end

  def datefield(form, object_name, label, date, css_class)
    opts = {label: label, class: css_class}
    unless date.nil?
      opts.merge!({value: l(date, format: :long), 'data-year' => date.year, 'data-month' => date.month, 'data-day' => date.day})
    end
    form.text_field object_name, opts
  end

  def display_in_hours(duration)
    hours = duration.to_hours.to_i
    minutes = (duration - hours * 1.hour).to_minutes.round
    is_negative = hours < 0 || minutes < 0

    if is_negative
      "-%02i:%02i" % [hours.abs, minutes.abs]
    else
      "%02i:%02i" % [hours, minutes]
    end
  end

  def icon_class_for_time_type(time_type)
    if time_type.icon.blank?
      'icon-sign-blank'
    else
      "icon-#{time_type.icon}"
    end
  end

  def icon_for_time_type(time_type)
    color_index = color_index_of_time_type(time_type)
    icon = icon_class_for_time_type(time_type)
    content_tag(:i, '', class: "event-color#{color_index} #{icon}")
  end

  def show_user_select?
    current_user.admin? or current_user.team_leader?
  end

  def user_path_time_sheet(user)
    time_sheet_path(user.current_time_sheet)
  end

  def user_path_absences(user)
    time_sheet_absences_path(user.current_time_sheet)
  end

  def user_path_my_work_summary(user)
    user_summaries_work_month_path(user, Date.current.year, Date.current.month)
  end

  def user_path_work_summary(user)
    user_summaries_work_month_path(user, Date.current.year, Date.current.month)
  end

  def user_path_absence_summary(user)
    user_summaries_absence_year_path(user, Date.current.year)
  end

  def selectable_users
    User.accessible_by(current_ability)
  end

end
