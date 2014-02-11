module ApplicationHelper
  include SessionsHelper
  include ReportsHelper
  include TimeSheetsHelper
  include AbsencesHelper

  def nav_link(name, link, match_controllers)
    if match_controllers.map(&:to_sym).include? controller.controller_name.to_sym
      classes = 'active'
    end
    link_to name, link, class: classes
  end

  def has_top_buttons?
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
    can?(:manage, TimeType) || can?(:manage, Employment) || can?(:manage, PublicHoliday) || can?(:manage, Project)
  end

  def activities_enabled?
    !UberZeit.config.disable_activities
  end

  def show_activities_link_in_navigation?
    can?(:manage, :billability) || can?(:manage, :billing) || can?(:read, Activity)
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

  def datefield(form = nil, object_name, label, date, css_class)
    opts = {label: label, class: css_class}
    unless date.nil?
      opts.merge!({'data-value' => l(date, format: :iso)})
    end
    if form
      form.text_field object_name, opts
    else
      text_field_tag object_name, nil, opts
    end
  end

  def display_in_hours(duration)
    rounded_duration = UberZeit.round(duration)
    UberZeit.duration_in_hhmm(rounded_duration)
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
    user_time_entries_path(user)
  end

  def user_path_absences(user)
    user_absences_path(user)
  end

  def user_path_my_work_summary(user)
    reports_work_user_month_path(user, Date.current.year, Date.current.month)
  end

  def selectable_users
    User.only_active.accessible_by(current_ability)
  end

  def time_types_in_absences(absences_per_day)
    all_absences = absences_per_day.values.flatten
    all_absences.collect(&:time_type).uniq
  end
end
