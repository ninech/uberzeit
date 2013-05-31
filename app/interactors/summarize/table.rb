class Summarize::Table
  attr_reader :entries

  # data structure:
  # { user1: {attribute1, attribute2, attribute3}, user2: {attribute1, attribute2, attribute3} }

  def initialize(summarizer, users, range)
    @range = range
    @users = users
    @summarizer = summarizer

    calculate
  end

  def total(attribute)
    @entries.inject(0.0) { |sum, (_, summary)| sum + summary[attribute] }
  end

  private

  def calculate
    @entries = {}
    @users.each { |user| @entries[user] = @summarizer.new(user, @range).summary }
  end
end
