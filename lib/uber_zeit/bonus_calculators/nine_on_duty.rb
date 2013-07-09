class UberZeit::BonusCalculators::NineOnDuty
  include UberZeit::BonusCalculators::BaseNightlyWindow

  FACTOR = 0.1
  ACTIVE = { ends: 6, starts: 23 }
  DESCRIPTION = 'Calculates the bonus for work during pikett'.freeze
  NAME = 'Nine On Duty Bonus'.freeze
end
