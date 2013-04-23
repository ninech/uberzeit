class Summaries::WorksController < ApplicationController
  include SummaryHelper

  load_and_authorize_resource :user

  def index
    @year = (params[:year] || Date.current.year).to_i
    @range = UberZeit.year_as_range(@year)

    @entries = User.all.collect do |user|
      entry = Summarize::User::Work.new(user, @range).total
      entry[:user] = user
      entry
    end
  end

  def show
    @year = (params[:year] || Date.current.year).to_i
    @range = UberZeit.year_as_range(@year)
    @ranges = generate_ranges(@range, 1.month)

    running_overtime = 0
    @entries = @ranges.collect do |range|
      entry = Summarize::User::Work.new(@user, range).total
      running_overtime += entry[:overtime]
      entry[:running_overtime] = running_overtime
      entry
    end
  end

  private

  def generate_ranges(range, interval, start_from = nil)
    cursor = start_from || range.min
    ranges = []
    while cursor <= range.max
      range_at_cursor = cursor...cursor+interval
      ranges.push(range_at_cursor.intersect(range))
      cursor += interval
    end
    ranges
  end
end
