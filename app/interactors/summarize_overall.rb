class SummarizeOverall
  def initialize(year, month = nil, team = nil)
    @team = team
    @year = year
    @month = month
  end

  def vacation
    users.collect do |user|
      total_redeemable = CalculateTotalRedeemableVacation.new(user, @year).total_redeemable_for_year
      redeemed_before = (1..@month-1).inject(0) { |sum, month_before| sum + SummarizeOverall.redeemed_in_month(user, @year, month_before) }
      redeemed_this_month = SummarizeOverall.redeemed_in_month(user, @year, @month)

      remaining = total_redeemable - (redeemed_before + redeemed_this_month)

      { user: user, total_redeemable: total_redeemable, redeemed_before: redeemed_before, redeemed_this_month: redeemed_this_month, remaining: remaining }
    end
  end

  private

  def users
    if @team.nil?
      User.all
    else
      @team.leaders_and_members
    end
  end

  def self.redeemed_in_month(user, year, month)
    range = UberZeit.month_as_range(year, month)
    CalculateRedeemedVacation.new(user, range).total
  end

end
