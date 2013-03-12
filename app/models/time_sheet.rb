class TimeSheet < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user

  has_many :time_entries # required by cancans' load_and_authorize_resource
  has_many :date_entries

  validates_presence_of :user

  # returns time chunks (which are limited to the given date or range)
  def find_chunks(date_or_range, time_type_scope = nil)
    TimeChunkCollection.new(date_or_range, [time_entries, date_entries], time_type_scope)
  end

  def total(date_or_range, type)
    chunks = find_chunks(date_or_range, type)

    chunks.total(type)
  end

  def overtime(date_or_range)
    Overtime.new(user, date_or_range).total
  end

  def vacation(year)
    current_year = Time.zone.now.beginning_of_year.to_date
    range = (current_year...current_year + 1.year)
    total(range, :vacation)
  end

  def remaining_vacation(year)
    user.vacation_available(year) - vacation(year)
  end
end
