module CommonEntry
  extend ActiveSupport::Concern

  included do
    acts_as_paranoid

    belongs_to :time_sheet
    belongs_to :time_type

    has_one :recurring_schedule, as: :enterable, dependent: :destroy

    attr_accessible :recurring_schedule, :recurring_schedule_attributes

    attr_accessible :time_sheet_id, :time_type_id, :type
    validates_presence_of :time_sheet, :time_type

    accepts_nested_attributes_for :recurring_schedule

    scope :work, joins: :time_type, conditions: ['is_work = ?', true]
    scope :absence, joins: :time_type, conditions: ['is_work = ?', false]
    scope :vacation, joins: :time_type, conditions: ['is_vacation = ?', true]

    before_validation :build_recurring_schedule, unless: :recurring_schedule
  end

  module ClassMethods
    def recurring_entries
      # inner join
      scoped.joins(:recurring_schedule).where(recurring_schedules: {active: true})
    end

    def nonrecurring_entries
      # left outer join
      scoped.includes(:recurring_schedule).where(recurring_schedules: {active: false})
    end

    def recurring_entries_in_range(range)
      recurring_entries.collect { |entry| entry if entry.recurring_schedule.occurring?(range) }.compact
    end

    def entries_in_range(range)
      recurring_entries_in_range(range) + nonrecurring_entries_in_range(range)
    end
  end

  def duration
    range.duration
  end

  def range
    (starts..ends)
  end

  def recurring?
    recurring_schedule && recurring_schedule.active?
  end

  def occurrences(date_or_range)
    if recurring?
      recurring_schedule.occurrences(date_or_range)
    else
      [self.starts]
    end
  end

end
