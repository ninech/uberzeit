class Entry < ActiveRecord::Base
  if Rails.env.development? # populate descendants in lazy loading environment
    %w(date_entry time_entry).each do |class_name|
      require_dependency File.join("app","models","#{class_name}.rb")
    end
  end

  acts_as_paranoid

  belongs_to :time_sheet
  belongs_to :time_type

  attr_accessible :time_sheet_id, :time_type_id, :type
  attr_accessible :start_date, :end_date
  attr_accessible :start_time, :end_time
  attr_accessible :first_half_day, :second_half_day

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
      chunks_in_range = entries_in_range.to_chunks
      clip_chunks(chunks_in_range, range)
    end.flatten

    chunks
  end

  def self.clip_chunks(chunks, clip_range)
    clipped_chunks = []
    # cnt = 0
    chunks.each do |chunk|
      intersected_range = chunk.range.intersect(clip_range)
      if intersected_range && intersected_range.duration > 0
        clipped_chunks << TimeChunk.new(range: intersected_range, time_type: chunk.time_type, parent: chunk.parent)
      end
    end
    clipped_chunks
  end

  def duration
    range.duration
  end

  def is_time?
    self.type == 'TimeEntry'
  end

  def is_date?
    self.type == 'DateEntry'
  end

  def to_type
    self.becomes(self.type.constantize) unless self.type.blank?
  end

  def to_entry
    self.becomes(Entry)
  end

  def range
    (starts..ends)
  end
end
