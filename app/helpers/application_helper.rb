module ApplicationHelper
  include TimeSheetsHelper

  def in_controller?(*args)
    args.find { |name| controller.controller_name == name }
  end

  def active_tab(*args)
    in_controller?(*args) ? 'active' : ''
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
end
