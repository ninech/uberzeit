class RecurringEntry < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :time_sheet
  belongs_to :time_type
  attr_accessible :schedule, :time_sheet, :time_type_id, :schedule_attributes
  
  serialize :schedule_hash, Hash

  scope :work, joins: :time_type, conditions: ['is_work = ?', true]
  scope :vacation, joins: :time_type, conditions: ['is_vacation = ?', true]
  scope :onduty, joins: :time_type, conditions: ['is_onduty = ?', true]
  
  # Inspiration from https://github.com/ableGray/Schedule-Attributes/blob/master/lib/schedule_atts.rb
  def schedule
    @schedule ||= begin
      if schedule_hash.empty?
        IceCube::Schedule.new(Date.today.to_time)
      else
        IceCube::Schedule.from_hash(schedule_hash)
      end
    end
  end

  def schedule_attributes=(options)
    options = options.dup

    options[:start_time] &&= Time.parse(options[:start_time].to_s)
    options[:end_time]   &&= Time.parse(options[:end_time].to_s)

    @schedule = IceCube::Schedule.new(options[:start_time], end_time: options[:end_time])

    rule =  case options[:repeat_unit]
            when 'daily'
              IceCube::Rule.daily(options[:daily_repeat_every].to_i)
            when 'weekly'
              # weekdays = options.collect do |key, value|
              #   match = key.match(/weekly_repeat_weekday_(?<day_nr>\w+)/)
              #   value == "1" && !match.nil? ? match['day_nr'].to_i : nil 
              # end.compact
              rule = IceCube::Rule.weekly(options[:weekly_repeat_every].to_i)
              unless options[:weekly_repeat_weekday].blank?
                rule.day(*options[:weekly_repeat_weekday].map(&:to_i))
              end
              rule
            when 'monthly'
              rule = IceCube::Rule.monthly(options[:monthly_repeat_every].to_i)
              if options[:monthly_repeat_by] == 'weekday'
                rule.day_of_week(options[:start_time].to_date.cwday => [1]) # on the first weekday X of month
              else
                rule.day_of_month(options[:start_time].to_date.day) # on the day X of month
              end
              rule
            when 'yearly'
              IceCube::Rule.yearly(options[:yearly_repeat_every].to_i)
            else
              raise "No valid repeat unit"
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
