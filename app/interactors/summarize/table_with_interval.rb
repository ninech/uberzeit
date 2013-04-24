class Summarize::TableWithInterval
  attr_reader :entries

  # data structure:
  # { range1: { user1: {attribute1, attribute2, attribute3}, user2: {attribute1, attribute2, attribute3} },
  #   range2: { user1: {attribute1, attribute2, attribute3}, user2: {attribute1, attribute2, attribute3} } }

  def initialize(summarizer, users, range, interval, start_from = range.min)
    @range = range
    @interval = interval
    @start_from = start_from
    @users = users
    @summarizer = summarizer

    calculate
  end

  def total(attribute)
    total = 0

    @entries.each_pair do |entry, user_summaries|
      user_summaries.each_pair { |user, summary| total += summary[attribute] }
    end

    total
  end

  private

  def calculate
    @entries = {}
    @totals = {}

    sub_ranges.each do |sub_range|
      @entries[sub_range] ||= {}
      @users.each { |user| @entries[sub_range][user] = @summarizer.new(user, sub_range).summary }
    end
  end

  def sub_ranges
    cursor = @start_from
    @sub_ranges = []
    while cursor <= @range.max
      range_at_cursor = cursor...cursor+@interval
      @sub_ranges.push(range_at_cursor.intersect(@range))
      cursor += @interval
    end
    @sub_ranges
  end
end
