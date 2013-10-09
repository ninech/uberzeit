module WeekViewHelper
  def load_day
    unless params[:date].nil?
      @day = Time.zone.parse(params[:date]).to_date
    end
    @day ||= Time.zone.today
  end

  def prepare_week_view
    @week     = @day.at_beginning_of_week..@day.at_end_of_week
    @weekdays = @week.to_a
    @year     = @week.min.year
    @previous_week_day = (@week.min - 1).at_beginning_of_week
    @next_week_day = @week.max + 1

    @public_holiday = PublicHoliday.with_date(@day).first

    @absences = {}
    @public_holidays = {}

    @weekdays.each do |weekday|
      absences =  @user.time_sheet.find_chunks(weekday, TimeType.absence)
      unless absences.empty?
        @absences[weekday] = absences.chunks
      end

      public_holiday = PublicHoliday.with_date(weekday).first
      if public_holiday
        @public_holidays[weekday] = public_holiday
      end
    end
  end
end
