class User < ActiveRecord::Base
  rolify
  acts_as_paranoid

  attr_accessible :uid, :name, :time_zone

  before_save :set_default_time_zone

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  has_many :time_sheets
  has_many :employments

  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone.zones_map { |m| m.name }, :message => "is not a valid Time Zone"

  before_validation :set_default_time_zone

  def subordinates
    # method chaining LIKE A BOSS
    teams.select{ |t| t.has_leader?(self) }.collect{ |t| t.members }.flatten.uniq
  end

  def create_time_sheet_if_needed
    time_sheets.create! if time_sheets.empty?
  end

  def create_employment_if_needed
    employments.create! if employments.empty?
  end

  def ensure_timesheet_and_employment_exist
    create_time_sheet_if_needed
    create_employment_if_needed
    self
  end

  # sollzeit
  def planned_work(date_or_range, fulltime=false)
    if date_or_range.kind_of?(Date)
      workload = fulltime ? 1 : workload_on(date_or_range) * 0.01
      total = workload * (UberZeit::is_work_day?(date_or_range) ? UberZeit::Config[:work_per_day] : 0)
    else
      raise "Expects a date range" unless date_or_range.min.kind_of?(Date)
      days = date_or_range.to_a
      days.pop # exclude the exclusive day
      total = days.inject(0.0) do |sum, date|
        workload = fulltime ? 1 : workload_on(date) * 0.01
        sum + workload * (UberZeit::is_work_day?(date) ? UberZeit::Config[:work_per_day] : 0)
      end
    end

    total
  end

  def workload_on(date)
    employment = self.employments.on(date)
    employment ? employment.workload : 0
  end

  def vacation_available(year)
    current_year = Time.zone.now.beginning_of_year.to_date
    range = (current_year..current_year + 1.year)
    employments = self.employments.between(range.min, range.max)

    default_vacation_per_year = UberZeit::Config[:vacation_per_year]/1.day*UberZeit::Config[:work_per_day]

    total = employments.inject(0.0) do |sum, employment|
      # contribution to this year
      if employment.open_ended?
        contrib_year = range.intersect((employment.start_date..current_year + 1.year)).duration
      else
        contrib_year = range.intersect((employment.start_date..employment.end_date)).duration
      end

      sum + employment.workload * 0.01 * contrib_year/range.duration * default_vacation_per_year
    end

    # round to half work days
    half_day = UberZeit::Config[:work_per_day]*0.5
    (total/half_day).round * half_day
  end

  def self.create_with_omniauth(auth)
    create! do |user|
      user.uid = auth['uid']
      user.name = auth['info']['name'] if auth['info']
    end
  end

  private

  def set_default_time_zone
    self.time_zone ||= Time.zone.name
  end
end
