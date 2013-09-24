class Summarize::Summarizer::Vacation
  attr_reader :summary

  SUMMARIZE_ATTRIBUTES = [:total_redeemable, :redeemed, :redeemed_until, :remaining]

  def initialize(user, range)
    @user = user
    @range = range
    @time_sheet = user.time_sheet

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

end
