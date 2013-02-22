class TimeSheet < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :user
  
  has_many :single_entries

  validates_presence_of :user

  # returns time chunks (which are limited to a single day for cleaner calculation)
  def chunks_for(date_or_range, time_type_scope = nil)
    range = date_or_range.to_range

    if time_type_scope.nil?
      filtered_singles = single_entries
    else
      # scope filter
      filtered_singles = single_entries.send(time_type_scope)
    end

    chunks = []
    
    chunks += filtered_singles.between(range.min, range.max).collect do |entry|
      TimeChunk.new(range: entry.range_for(range), time_type: entry.time_type, parent: entry)
    end

    chunks
  end

  def total_duration_for(date_or_range, type)
    scope = type

    case type
    when :overtime
      scope = :work
    end

    chunks = chunks_for(date_or_range, scope)

    total = chunks.inject(0) do |sum, chunk|
      sum + chunk.duration
    end

    if type == :overtime
      total -= UberZeit::total_default_work_duration_for(date_or_range)
    end

    total
  end
end
