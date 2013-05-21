class Summarize::Summarizer::Work
  attr_reader :summary

  SUMMARIZE_ATTRIBUTES = [:planned_work, :effective_worked, :effective_worked_by_type, :absent, :absent_by_type, :time_bonus, :overtime]

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
    Hash[SUMMARIZE_ATTRIBUTES.collect { |summarize_attribute| [summarize_attribute, method(summarize_attribute).call] }]
  end

  def planned_work
    CalculatePlannedWorkingTime.new(@range, @user).total
  end

  def effective_worked
    total_of_time_sheet(TimeType.work)
  end

  def effective_worked_by_type
    TimeType.work.each_with_object({}) { |time_type, hash| hash[time_type] = total_of_time_sheet(time_type) }
  end

  def absent
    total_of_time_sheet(TimeType.absence)
  end

  def absent_by_type
    TimeType.absence.each_with_object({}) { |time_type, hash| hash[time_type] = total_of_time_sheet(time_type) }
  end

  def time_bonus
    @time_sheet && @time_sheet.bonus(@range, TimeType.work) or 0
  end

  def overtime
    @time_sheet && @time_sheet.overtime(@range) or 0
  end

  def total_of_time_sheet(time_types)
    @time_sheet && @time_sheet.total(@range, time_types) or 0
  end
end
