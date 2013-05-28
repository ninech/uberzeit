class Summarize::Summarizer::Absences
  attr_reader :summary

  def initialize(user, range)
    @user = user
    @range = range
    @time_sheet = user.current_time_sheet # ToDo: For all time sheets of the current user

    calculate
  end

  private

  def calculate
    @summary ||= summarize
  end

  def summarize
    Hash[TimeType.absence.collect { |time_type| [time_type, sum_of_time_type(time_type)] }]
  end

  def sum_of_time_type(time_type)
    return 0 if @time_sheet.nil?

    chunks = @time_sheet.find_chunks(@range, time_type)
    chunks.ignore_exclusion_flag = true # include time types with exclusion flag in calculation (e.g. compensation)

    total = if time_type.is_vacation?
              # vacation adjustments are added to the reedemable days
              chunks.total
            else
              chunks.total + duration_of_adjustments(time_type)
            end
  end

  def duration_of_adjustments(time_type)
    @time_sheet.adjustments.where(time_type_id: time_type).in(@range).sum(&:duration)
  end
end
