module ApplicationHelper
  include TimeSheetsHelper

  def nav_link(name, link, match_controllers)
    if match_controllers.include? controller.controller_name.to_sym
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
  end

  def color_index_of_element(element)
    color_index_of_time_type(element.time_type)
  end

  def color_index_of_time_type(time_type)
    TimeType.all.index(time_type)
  end

  def datefield(form, object_name, label, date, css_class)
    opts = {label: label, class: css_class}
    unless date.nil?
      opts.merge!({value: l(date, format: :long), 'data-year' => date.year, 'data-month' => date.month, 'data-day' => date.day})
    end
    form.text_field object_name, opts
  end
end
