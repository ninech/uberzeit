class SummarizeOverall
  def initialize(year, month = nil, team = nil)
    @team = team
    @year = year
    @month = month
  end

  def vacation
    users.collect { |user| vacation_summary_for_user(user) }
  end

  private

  def vacation_summary_for_user(user)
    total_redeemable = CalculateTotalRedeemableVacation.new(user, @year).total_redeemable_for_year

    if @month.nil?
      redeemed = SummarizeOverall.redeemed_in_year(user, @year)
      remaining = total_redeemable - redeemed
    else
      redeemed_before = (1..@month-1).inject(0) { |sum, month_before| sum + SummarizeOverall.redeemed_in_month(user, @year, month_before) }
      redeemed = SummarizeOverall.redeemed_in_month(user, @year, @month)
      remaining = total_redeemable - (redeemed_before + redeemed)
    end

    { user: user, total_redeemable: total_redeemable, redeemed: redeemed, remaining: remaining }
  end

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

  def self.redeemed_in_year(user, year)
    range = UberZeit.year_as_range(year)
    CalculateRedeemedVacation.new(user, range).total
  end
end
