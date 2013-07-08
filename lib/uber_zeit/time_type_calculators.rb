module UberZeit::TimeTypeCalculators

  @@available_calculators = []
  mattr_reader :available_calculators

  def self.register(identifier, calculator)
    @@available_calculators << {identifier => calculator}
  end

end
