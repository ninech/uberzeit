require 'spec_helper'

describe UberZeit::BonusCalculators do

  let(:my_calculator) { Class.new { def initialize(args); end } }

  it 'allows to register a new calculator' do
    UberZeit::BonusCalculators.register :my_calc, my_calculator
    UberZeit::BonusCalculators.available_calculators.should include(my_calc: my_calculator)
  end

  describe '.use' do
    before do
      UberZeit::BonusCalculators.register :my_calc, my_calculator
    end

    it 'returns the specified registered calculator' do
      UberZeit::BonusCalculators.use(:my_calc, mock).should be_instance_of(my_calculator)
    end

    it 'returns a dummy calculator if the requested calculator is nil' do
      UberZeit::BonusCalculators.use(nil, mock).should be_instance_of(UberZeit::BonusCalculators::Dummy)
    end
    it 'returns a dummy calculator if the requested calculator is an empty string' do
      UberZeit::BonusCalculators.use('', mock).should be_instance_of(UberZeit::BonusCalculators::Dummy)
    end
  end

end
