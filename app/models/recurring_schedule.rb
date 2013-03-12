class RecurringSchedule < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible   :active, :ends, :ends_counter, :ends_date, :entry, :repeat_interval_type,
                    :daily_repeat_interval,
                    :monthly_repeat_by, :monthly_repeat_interval,
                    :weekly_repeat_interval, :weekly_repeat_weekday,
                    :yearly_repeat_interval

  validates :repeat_interval_type, inclusion: { in: %w(daily weekly monthly yearly) }
  validates :ends, inclusion: { in: %w(never counter date) }

  serialize :weekly_repeat_weekday

  belongs_to :enterable, polymorphic: true

  def active?
    !!active
  end

end
