class Entry < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :time_sheet
  belongs_to :time_type

  attr_accessible :time_sheet_id, :time_type_id
  attr_accessible :start_date, :end_date
  attr_accessible :start_time, :end_time

  scope :work, joins: :time_type, conditions: ['is_work = ?', true]
  scope :vacation, joins: :time_type, conditions: ['is_vacation = ?', true]
  scope :onduty, joins: :time_type, conditions: ['is_onduty = ?', true]

  def self.find_chunks(date_or_range, time_type_scope = nil)
    range = date_or_range.to_range

    chunks = descendants.collect do |descendant|
      scope_to_search_on = if time_type_scope
                             descendant.send(time_type_scope)
                           else
                             descendant.scoped
                           end

      entries_in_range = scope_to_search_on.between(range)
      clip_entries(entries_in_range, range)
    end.flatten

    chunks
  end

  def self.clip_entries(entries, range)
    entries.collect do |entry|
      TimeChunk.new(range: entry.range.intersect(range), time_type: entry.time_type, parent: entry)
    end
  end

  def duration
    range.duration
  end

  def range
    (starts..ends)
  end

  def self.descendants
    [DateEntry,TimeEntry]
  end
end
