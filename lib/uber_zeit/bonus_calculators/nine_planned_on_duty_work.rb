class UberZeit::BonusCalculators::NinePlannedOnDutyWork
  include UberZeit::BonusCalculators::BaseNightlyWindow

  FACTOR = 0.25
  ACTIVE = { ends: 6, starts: 23 }
  DESCRIPTION = 'Calculates the bonus for planned work during on duty hours'.freeze
  NAME ='Nine Planned Work During OnDuty Hours Bonus'.freeze
end
