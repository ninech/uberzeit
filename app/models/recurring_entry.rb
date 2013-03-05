class RecurringEntry < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :time_sheet
  belongs_to :time_type
  attr_accessible :schedule, :time_sheet, :time_type_id, :schedule_attributes
  
  serialize :schedule_hash, Hash

  scope :work, joins: :time_type, conditions: ['is_work = ?', true]
  scope :vacation, joins: :time_type, conditions: ['is_vacation = ?', true]
  scope :onduty, joins: :time_type, conditions: ['is_onduty = ?', true]
  
  def self.find_chunks(date_or_range, time_type_scope = nil)
    chunks_range = date_or_range.to_range

    ref = time_type_scope.nil? ? self.all : self.send(time_type_scope)
    ref.collect do |entry|
      opening_time = chunks_range.min
      closing_time = chunks_range.max

      # IceCube Bug https://github.com/seejohnrun/ice_cube/issues/152
      # Make sure the time zones are identical to the schedules' zone
      if opening_time.kind_of?(Time) 
        opening_time = opening_time.in_time_zone(entry.schedule.start_time.zone)
        closing_time = closing_time.in_time_zone(entry.schedule.start_time.zone)
      end

      schedule = entry.schedule

      # Subtract the duration to make sure the requested time window is below the start time of the entry's start time if intersecting
      # cf. https://github.com/seejohnrun/ice_cube/issues/153
      schedule.occurrences_between(opening_time - schedule.duration, closing_time).each_with_object([]) do |occurrence, chunks|
        # make sure we use rails' time zone
        starts = occurrence.start_time.in_time_zone(Time.zone)
        intersect = chunks_range.intersect(starts..starts+schedule.duration)
        unless intersect.nil?
          chunks << TimeChunk.new(range: intersect, time_type: entry.time_type, parent: entry) 
        end
      end
    end.flatten
  end

  # Inspiration from https://github.com/ableGray/Schedule-Attributes/blob/master/lib/schedule_atts.rb
  def schedule
    @schedule ||= begin
      if schedule_hash.empty?
        IceCube::Schedule.new(Date.today.midnight)
      else
        IceCube::Schedule.from_hash(schedule_hash)
      end
    end
  end

  def schedule_attributes=(options)
    options = options.dup

    # Time zone information needs to be preserved in the schedule for DST
    options[:start_time] &&= Time.zone.parse(options[:start_time].to_s)
    options[:end_time]   &&= Time.zone.parse(options[:end_time].to_s)

    @schedule = IceCube::Schedule.new(options[:start_time], end_time: options[:end_time])

    rule =  case options[:repeat_unit]
            when 'daily'
              IceCube::Rule.daily(options[:daily_repeat_every].to_i)
            when 'weekly'
              rule = IceCube::Rule.weekly(options[:weekly_repeat_every].to_i)
              unless options[:weekly_repeat_weekday].blank?
                rule.day(*options[:weekly_repeat_weekday].map(&:to_i))
              end
              rule
            when 'monthly'
              rule = IceCube::Rule.monthly(options[:monthly_repeat_every].to_i)
              if options[:monthly_repeat_by] == 'weekday'
                rule.day_of_week(options[:start_time].to_date.wday => [1]) # on the first weekday X of month
              else
                rule.day_of_month(options[:start_time].to_date.day) # on the day X of month
              end
              rule
            when 'yearly'
              IceCube::Rule.yearly(options[:yearly_repeat_every].to_i)
            else
              raise "No valid repeat unit"
            end
    
    case options[:ends]
    when 'counter'
      counter = options[:ends_counter].to_i
      rule.count(counter)
    when 'date'
      date = Date.parse(options[:ends_date])
      rule.until(date)
    end

    @schedule.add_recurrence_rule rule

    self.schedule_hash = @schedule.to_hash
  end

  def schedule_attributes
    atts = {}

    atts[:start_time] = schedule.start_time
    atts[:end_time] = schedule.end_time

    unless schedule.recurrence_rules.empty?
      rule = schedule.recurrence_rules.first
      rhash = rule.to_hash

      if rhash[:count] 
        atts[:ends] = 'counter'
        atts[:ends_counter] = rhash[:count]
      elsif rhash[:until]
        atts[:ends] = 'date'
        atts[:ends_date] = rhash[:until].to_date
      else
        atts[:end] = 'never'
      end

      case rule
      when IceCube::DailyRule
        atts[:repeat_unit] = 'daily'
        atts[:daily_repeat_every] = rhash[:interval]
      when IceCube::WeeklyRule
        atts[:repeat_unit] = 'weekly'
        atts[:weekly_repeat_weekday] = rhash[:validations][:day]
        atts[:weekly_repeat_every] = rhash[:interval]
      when IceCube::MonthlyRule
        atts[:repeat_unit] = 'monthly'
        atts[:monthly_repeat_every] = rhash[:interval]
        atts[:monthly_repeat_by] = 'day'
        if rhash[:validations].present? && rhash[:validations][:day_of_week].present?
          atts[:monthly_repeat_by] = 'weekday'
        end
      when IceCube::YearlyRule
        atts[:repeat_unit] = 'yearly'
        atts[:yearly_repeat_every] = rhash[:interval]
      end
    end

    OpenStruct.new(atts)
  end

  def start_time
    schedule_attributes.start_time
  end

  def end_time
    schedule_attributes.end_time
  end
end
