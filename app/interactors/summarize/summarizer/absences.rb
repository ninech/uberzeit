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
    chunks = @time_sheet.find_chunks(@range, time_type)
    chunks.ignore_exclusion_flag = true # include time types with exclusion flag in calculation (e.g. compensation)
    chunks.total
  end
end
