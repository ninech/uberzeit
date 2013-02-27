module ApplicationHelper
  def in_controller?(*args)
    args.find { |name| controller.controller_name == name }
  end

  def active_tab(*args)
    in_controller?(*args) ? 'active' : ''
  end
end
