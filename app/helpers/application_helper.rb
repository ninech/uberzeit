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
end
