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
end
