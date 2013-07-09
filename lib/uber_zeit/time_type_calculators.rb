module UberZeit::TimeTypeCalculators

  @@available_calculators = HashWithIndifferentAccess.new
  mattr_reader :available_calculators

  def self.register(identifier, calculator)
    @@available_calculators[identifier] = calculator
  end

  def self.use(identifier, params)
    return UberZeit::TimeTypeCalculators::Dummy.new if identifier.blank?
    @@available_calculators[identifier].new(params)
  end

end
