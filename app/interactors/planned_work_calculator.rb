class PlannedWorkCalculator

  def initialize(user, date_or_range)
    @user = user
    if date_or_range.kind_of?(Date)
      @date = date_or_range
    else
      @array = sanitize_range(date_or_range)
    end
  end

  def employment_dependent
    if @date
      employment_dependent_with_date
    else
      employment_dependent_with_range
    end
  end

  def employment_dependent_with_date
    return 0 unless UberZeit.is_work_day?(@date)
    workload * UberZeit::Config[:work_per_day]
  end

  def employment_dependent_with_range
    @array.to_a.inject(0.0) do |sum, date|
      @date = date
      sum + employment_dependent_with_date
    end
  end

  def fulltime_employment
    if @date
      fulltime_employment_with_date
    else
      fulltime_employment_with_range
    end
  end

  def fulltime_employment_with_date
    return 0 unless UberZeit.is_work_day?(@date)
    if employed_on?
      UberZeit::Config[:work_per_day]
    else
      0
    end
  end

  def fulltime_employment_with_range
    @array.to_a.inject(0.0) do |sum, date|
      @date = date
      sum + fulltime_employment_with_date
    end
  end

  private
  def workload
    workload_percentage.to_f / 100
  end

  def workload_percentage
    if employed_on?
      employment_on.workload
    else
      0
    end
  end

  def employed_on?
    !@user.employments.on(@date).nil?
  end

  def employment_on
    @user.employments.on(@date)
  end

  def sanitize_range(range)
    range.to_a.tap do |arr|
      arr.pop unless range.exclude_end?
    end
  end

end
