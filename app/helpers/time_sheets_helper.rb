module TimeSheetsHelper
  def format_duration(duration, type=nil, format=:hours)
    cls = ''
    unless type.nil?
      cls = "label label-#{time_type_css(type)}"
    end
    content_tag :span, :class => cls do 
      unit = "h"
      case format
      when :days 
        unit = "d"
      when :work_days
        unit = "d"
      end

      "#{duration.send("to_#{format}")} #{unit}"
    end
  end

  def time_type_css(type)
    case 
    when is_type?(type, :work)
      'success'
    when is_type?(type, :vacation)
      'info'
    when is_type?(type, :onduty)
      'important'
    when is_type?(type, :overtime)
      'inverse'
    else
      'default'
    end
  end

  private

  # for symbols and time_type model
  def is_type?(type, check_for)
    return type == check_for unless type.respond_to?("is_#{check_for}")
    type.send("is_#{check_for}") == true
  end
end
