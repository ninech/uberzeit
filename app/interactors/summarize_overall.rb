class SummarizeOverall
  def initialize(year_or_range, team = nil)

  end

  def vacation


  end

  private

  def employees
    if @team.nil?
      @team.leaders_and_members
    else
      User.all
    end
  end
end
