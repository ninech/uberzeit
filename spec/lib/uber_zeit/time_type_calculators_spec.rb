require 'spec_helper'

describe UberZeit::TimeTypeCalculators do

  it 'allows to register a new calculator' do
    DummyCalculator = Class.new
    UberZeit::TimeTypeCalculators.register :dummy, DummyCalculator
    UberZeit::TimeTypeCalculators.available_calculators.should eq([{dummy: DummyCalculator}])
  end

end
