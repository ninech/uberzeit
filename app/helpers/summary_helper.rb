module SummaryHelper
  def format_work_days(duration)
    color = if duration == 0
              'gray'
            else
              ''
            end

    content_tag(:span, number_with_precision(duration.to_work_days, precision: 1), style: "color: #{color}")
  end

  def format_hours(duration)
    color = if duration == 0
            'gray'
          elsif duration < 0
            'tomato'
          else
            ''
          end

    content_tag(:span, number_with_precision(duration.to_hours, precision: 2), style: "color: #{color}")
  end
end
