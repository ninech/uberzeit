class Summarize::Summarizer::Vacation
  attr_reader :summary

  def initialize(user, range)
    @user = user
    @range = range
    @time_sheet = user.current_time_sheet # ToDo: For all time sheets of the current user

    calculate
  end

  private

  def calculate
    @summary ||= summarize
  end

  def summarize
    year = @range.min.year
    year_as_range = UberZeit.year_as_range(@range.min.year)


    total_redeemable= CalculateTotalRedeemableVacation.new(@user, year).total_redeemable_for_year
    redeemed_until =  if year_as_range.min < @range.min
                        until_range = year_as_range.min...@range.min
                        CalculateRedeemedVacation.new(@user, until_range).total
                      else
                        0
                      end
    redeemed = CalculateRedeemedVacation.new(@user, @range).total

    remaining = total_redeemable - (redeemed + redeemed_until)

    { total_redeemable: total_redeemable, redeemed: redeemed, redeemed_until: redeemed_until, remaining: remaining }
  end

  def sum_of_time_type(time_type)
    return 0 if @time_sheet.nil?

    chunks = @time_sheet.find_chunks(@range, time_type)
    chunks.ignore_exclusion_flag = true # include time types with exclusion flag in calculation (e.g. compensation)
    chunks.total
  end
end
