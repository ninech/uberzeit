class FindAbsences
  def initialize(user, date_or_range)
    @user = user
    @range = date_or_range.to_range.to_date_range
  end

  def personal_absences
    @personal_absences ||= find_personal_absences
  end

  def team_absences
    @team_absences ||= find_team_absences
  end

  private

  def find_personal_absences
    absences_to_chunks_per_day(personal_time_sheets)
  end

  def find_team_absences
    absences_to_chunks_per_day(team_time_sheets)
  end

  def absences_to_chunks_per_day(time_sheets)
    chunks = {}
    time_sheets.each do |ts|
      daily_time_chunks_for(ts.absences) do |date, chunk|
        chunks[date] ||= []
        chunks[date] << chunk
      end
    end
    chunks
  end

  def daily_time_chunks_for(entries)
    time_chunks_finder = FindTimeChunks.new(entries)
    time_chunks_finder.in_range(@range).each do |chunk|
      chunk.range.to_date_range.each do |date|
        yield(date, chunk)
      end
    end
  end

  def personal_time_sheets
    [@user.current_time_sheet]
  end

  def team_time_sheets
    @team_time_sheets ||= TimeSheet.joins(:user => :teams).where(memberships: {team_id: @user.teams}).uniq.where('users.id != ?', @user)
  end

end
