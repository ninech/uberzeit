class TimeSheet < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :user
  
  has_many :single_entries
  has_many :recurring_entries

  validates_presence_of :user

  # returns time chunks (which are limited to the given date or range)
  def find_chunks(date_or_range, time_type_scope = nil)
    chunks = []
    chunks += single_entries.find_chunks(date_or_range, time_type_scope)
    chunks += recurring_entries.find_chunks(date_or_range, time_type_scope)

    chunks
  end

  def total(date_or_range, type)
    chunks = find_chunks(date_or_range, type)

    total = chunks.inject(0) do |sum, chunk|
      duration = chunk.duration

      if chunk.parent.respond_to?(:whole_day?) && chunk.parent.whole_day?
        duration = (chunk.starts.to_date...chunk.ends.to_date).inject(0) do |sum_chunk, date| 
          # whole day is independent of users workload
          sum_chunk + user.planned_work(date, true)
        end
      end
      
      sum + duration
    end

    total
  end

  def overtime(date_or_range)
    if date_or_range.kind_of?(Date) 
      date = date_or_range
      workload = user.workload_on(date)

      if workload >= 100
        # For full time position, the overtime per day is based on the excess of time relative to the planned work per day
        remaining_work_on_date = user.planned_work(date) - total(date, :vacation)
      else
        # special case for people with no fulltime position
        # calculate the daily overtime not based on the daily work hour (because it might be like 6.8 hours for 80% workload)
        # but calculate the overtime based on the status of the current week
        week_until_today = date.monday..date.to_date
        whole_week = date.monday..date.next_week

        effective_planned_work = user.planned_work(whole_week) - total(whole_week, :vacation)
        remaining_work_on_date = [effective_planned_work - total(week_until_today, :work), 0].max
      end

      overtime = [total(date, :work) - remaining_work_on_date, 0].max
    else
      effective_planned_work = user.planned_work(date_or_range) - total(date_or_range, :vacation)
      overtime = total(date_or_range, :work) - effective_planned_work
    end
  end

  def vacation(year)
    current_year = Time.zone.now.beginning_of_year.to_date
    range = (current_year..current_year + 1.year)
    total(range, :vacation)
  end

  def remaining_vacation(year)
    user.vacation_available(year) - vacation(year)
  end
end
