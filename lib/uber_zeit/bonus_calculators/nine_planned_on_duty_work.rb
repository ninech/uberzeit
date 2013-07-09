class UberZeit::BonusCalculators::NinePlannedOnDutyWork
  include UberZeit::BonusCalculators::BaseNightlyWindow

  FACTOR = 0.25
  ACTIVE = { ends: 6, starts: 23 }
  DESCRIPTION = 'Calculates the bonus for planned worktime during the Nine OnDuty hours'.freeze
  NAME ='Planned Work During OnDuty Hours'.freeze
end
