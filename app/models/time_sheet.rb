class TimeSheet < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :user
  
  has_many :single_entries

  validates_presence_of :user

  # returns time chunks (which are limited to the given date or range)
  def find_chunks(date_or_range, time_type_scope = nil)
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

  def total(date_or_range, type)
    scope = type

    chunks = find_chunks(date_or_range, scope)

    total = chunks.inject(0) do |sum, chunk|
      duration = chunk.duration

      if chunk.parent.whole_day?
        # whole work day is independent of users workload
        duration = UberZeit::planned_work(user, chunk.starts.to_date, true)
      end

      sum + duration
    end

    total
  end

  def overtime(date_or_range)
    if date_or_range.kind_of?(Date) 
      date = date_or_range
      workload = UberZeit::workload_at(user, date_or_range)

      if workload >= 100
        # For full time position, the overtime per day is based on the excess of time relative to the planned work per day
        remaining_work_at_date = UberZeit::planned_work(user, date)
      else
        # special case for people with no fulltime position
        # calculate the daily overtime not on base of the daily work hour (because it might be like 6.8 hours for 80% workload)
        # but calculate the overtime on the status of the current week
        planned_week = UberZeit::planned_work(user, (date.monday..date.sunday))
        remaining_work_at_date = [planned_week - total((date.monday..date.to_date), :work),0].max
      end

      overtime = [total(date, :work) - remaining_work_at_date,0].max
    else
      overtime = total(date_or_range, :work) - UberZeit::planned_work(user, date_or_range)
    end
  end

  def vacation(year)
    current_year = Time.zone.now.beginning_of_year
    range = (current_year..current_year + 1.year)
    total(range, :vacation)
  end

  def remaining_vacation(year)
    UberZeit::total_vacation(user, year) - vacation(year)
  end
end
