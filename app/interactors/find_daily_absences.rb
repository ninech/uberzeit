class FindDailyAbsences
  attr_reader :users, :range

  def initialize(users, range)
    @users = users
    @range = range
  end

  def result
    @result ||= absences_by_time_spans(find_time_spans).uniq
  end

  def result_grouped_by_date
    @result_grouped_by_date ||= begin
      grouped_time_spans = find_time_spans.order(:date).group_by { |ts| ts.date }
      Hash[grouped_time_spans.collect{ |date, time_spans| [date, absences_by_time_spans(time_spans)] }]
    end
  end

  private

  def absences_by_time_spans(time_spans)
    Absence.joins(:time_spans)
           .where(time_spans: {id: time_spans})
           .includes(:time_type)
           .includes(:schedule => :absence) # Absences.first.schedule.occurrences -> Schedule will load absence again... EAGER LOADING TO THE RESCUE!
  end

  def find_time_spans
    TimeSpan.absences.for_user(users).with_date(range)
  end
end
