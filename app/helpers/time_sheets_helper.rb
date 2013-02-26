module TimeSheetsHelper
  def format_duration(duration, type=nil, format=:hours)
    cls = ''
    unless type.nil?
      cls = "label label-#{time_type_css(type)}"
    end
    content_tag :span, :class => cls do 

      case format
      when :hours
        format_hours(duration)
      when :days 
        format_days(duration)
      when :work_days
        format_work_days(duration)
      end

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

  def format_days(time)
    "%.1fd" % time.to_days 
  end

  def format_work_days(time)
    "%.1fd" % time.to_work_days 
  end

  def format_hours(time)
    h = (time.round.to_f / 60.minutes).to_i
    m = (time.round.to_f - h * 1.hour).to_minutes.to_i.abs
    [ h != 0 ? "#{h}h" : nil, m != 0 || h == 0 ? "#{m}min" : nil ].compact.join(' ')
  end

  # for symbols and time_type model
  def is_type?(type, check_for)
    return type == check_for unless type.respond_to?("is_#{check_for}")
    type.send("is_#{check_for}") == true
  end
end
