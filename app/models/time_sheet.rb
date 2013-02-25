class TimeSheet < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :user
  
  has_many :single_entries

  validates_presence_of :user

  # returns time chunks (which are limited to the given date or range)
  def chunks_for(date_or_range, time_type_scope = nil)
    range = date_or_range.to_range

    if time_type_scope.nil?
      filtered_singles = single_entries
    else
      # scope filter
      filtered_singles = single_entries.send(time_type_scope)
    end

    chunks = []
    
    chunks += filtered_singles.between(range.min, range.max).collect do |entry|
      TimeChunk.new(range: entry.range_for(range), time_type: entry.time_type, parent: entry)
    end

    chunks
  end

  def total_duration_for(date_or_range, type)
    scope = type

    chunks = chunks_for(date_or_range, scope)

    total = chunks.inject(0) do |sum, chunk|
      duration = chunk.duration
      if duration == 1.day
        # 1 day equals to a whole work day, independent of users workload
        duration = UberZeit::total_planned_work_duration(user, chunk.start_time.to_date, true)
      end

      sum + duration
    end

    total
  end

  def total_overtime_for(date_or_range)
    if date_or_range.kind_of?(Date) && user.employments.when(date_or_range).first.workload < 100
      # special case for people with no fulltime position
      # calculate the daily overtime not on base of the daily work hour (because it might be like 6.8 hours for 80% workload)
      # but calculate the overtime on the status of the current week
      date = date_or_range
      
      planned_week = UberZeit::total_planned_work_duration(user, (date.monday..date.sunday))
      remaining_work_hours = [planned_week - total_duration_for((date.monday..date.to_date), :work),0].max
      
      overtime = [total_duration_for(date, :work) - remaining_work_hours,0].max
    else
      overtime = total_duration_for(date_or_range, :work) - UberZeit::total_planned_work_duration(user, date_or_range)
    end
  end

  def total_vacation_for(year)
    range = (Time.utc(year)..Time.utc(year+1))
    total_duration_for(range, :vacation)
  end

  def total_remaining_vacation_for(year)
    UberZeit::total_available_vacation_duration(user, year) - total_vacation_for(year)
  end
end
