class UberZeit::BonusCalculators::NineOnDuty
  include UberZeit::BonusCalculators::BaseNightlyWindow

  FACTOR = 0.1
  ACTIVE = { ends: 6, starts: 23 }
end
