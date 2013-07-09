class UberZeit::BonusCalculators::NineOnDuty
  include UberZeit::BonusCalculators::BaseNightlyWindow

  FACTOR = 0.1
  ACTIVE = { ends: 6, starts: 23 }
  DESCRIPTION = 'Calculates the bonus for worktime during the Nine OnDuty hours'.freeze
  NAME = 'OnDuty Hours'.freeze
end
