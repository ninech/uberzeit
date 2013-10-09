class Reports::Work::MyWorkController < ApplicationController

  load_and_authorize_resource :user

  def year
    @year = params[:year].to_i

    @range = UberZeit.year_as_range(@year)
    @users = [@user]

    @buckets = UberZeit.range_to_buckets(@range, 1.month, @range.min)
  end

  def month
    @month = params[:month].to_i
    @year = params[:year].to_i

    @range = UberZeit.month_as_range(@year, @month)
    @users = [@user]

    @buckets = UberZeit.range_to_buckets(@range, 1.week, @range.min.beginning_of_week)
  end
end
