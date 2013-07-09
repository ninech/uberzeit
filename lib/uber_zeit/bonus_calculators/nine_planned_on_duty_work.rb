class UberZeit::BonusCalculators::NinePlannedOnDutyWork
  include UberZeit::BonusCalculators::BaseNightlyWindow

  FACTOR = 0.25
  ACTIVE = { ends: 6, starts: 23 }
end
