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
    absences_sum = TimeType.absence.collect { |absence| [absence, sum_of_absence(absence)] }
    Hash[absences_sum]
  end

  def sum_of_absence(absence)
    chunks = @time_sheet.find_chunks(@range, absence)
    chunks.ignore_exclusion_flag = true # include all time types, even those with the calculation exclusion flag set (e.g. compensation)

    total = if absence.is_vacation?
              # vacation adjustments are added to the reedemable days
              chunks.total
            else
              chunks.total + duration_of_adjustments(absence)
            end
  end

  def duration_of_adjustments(absence)
    @time_sheet.adjustments.where(time_type_id: absence).in(@range).total_duration
  end
end
