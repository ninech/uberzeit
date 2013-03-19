class PublicHoliday < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :end_date, :first_half_day, :name, :second_half_day, :start_date

  scope :on, lambda { |date| date = date.to_date; { conditions: ['(start_date <= ? AND end_date >= ?)', date, date] } }

  def self.half_day_on?(date)
    flag_on_date(date, :half_day?)
  end

  def self.whole_day_on?(date)
    flag_on_date(date, :whole_day?)
  end

  def whole_day?
    not half_day?
  end

  def half_day?
    first_half_day? or second_half_day?
  end

  def first_half_day?
    !!first_half_day and not !!second_half_day
  end

  def second_half_day?
    !!second_half_day and not !!first_half_day
  end

  private
  def self.flag_on_date(date, flag_sym)
    public_holidays_on_date = on(date)

    flag = false
    public_holidays_on_date.each do |public_holiday|
      flag ||= public_holiday.send(flag_sym)
    end
    flag
  end
end
