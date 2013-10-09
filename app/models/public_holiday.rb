# == Schema Information
#
# Table name: public_holidays
#
#  id              :integer          not null, primary key
#  date            :date
#  name            :string(255)
#  first_half_day  :boolean          default(FALSE)
#  second_half_day :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deleted_at      :datetime
#

require_relative 'concerns/dated'

class PublicHoliday < ActiveRecord::Base
  include Dated

  acts_as_paranoid

  default_scope order(:date)

  attr_accessible :first_half_day, :name, :second_half_day, :date, :daypart

  validates_presence_of :name, :date

  validates_datetime :date, allow_blank: true

  scope_date :date

  after_save :update_days

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
  alias_method :half_day_specific?, :half_day?

  def first_half_day?
    !!first_half_day and not !!second_half_day
  end

  def second_half_day?
    !!second_half_day and not !!first_half_day
  end

  def daypart
    case
    when whole_day?
      :whole_day
    when first_half_day?
      :first_half_day
    when second_half_day?
      :second_half_day
    end
  end

  def daypart=(value)
    case value.to_sym
    when :whole_day
      self.first_half_day = true
      self.second_half_day = true
    when :first_half_day
      self.first_half_day = true
      self.second_half_day = false
    when :second_half_day
      self.first_half_day = false
      self.second_half_day = true
    end
  end

  def on_date?(check_date)
    date == check_date
  end

  def update_days
    changed_dates = [date, date_was].compact
    Day.where(date: changed_dates).each(&:regenerate!)
  end

  private
  def self.flag_on_date(date, flag_sym)
    flag = false
    with_date(date).each do |public_holiday|
      flag ||= public_holiday.send(flag_sym)
    end
    flag
  end
end
