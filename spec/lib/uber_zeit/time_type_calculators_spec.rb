require 'spec_helper'

describe UberZeit::TimeTypeCalculators do

  let(:my_calculator) { Class.new { def initialize(args); end } }

  it 'allows to register a new calculator' do
    UberZeit::TimeTypeCalculators.register :my_calc, my_calculator
    UberZeit::TimeTypeCalculators.available_calculators.should include(my_calc: my_calculator)
  end

  describe '.use' do
    before do
      UberZeit::TimeTypeCalculators.register :my_calc, my_calculator
    end

    it 'returns the specified registered calculator' do
      UberZeit::TimeTypeCalculators.use(:my_calc, mock).should be_instance_of(my_calculator)
    end

    it 'returns a dummy calculator if the requested calculator is nil' do
      UberZeit::TimeTypeCalculators.use(nil, mock).should be_instance_of(UberZeit::TimeTypeCalculators::Dummy)
    end
    it 'returns a dummy calculator if the requested calculator is an empty string' do
      UberZeit::TimeTypeCalculators.use('', mock).should be_instance_of(UberZeit::TimeTypeCalculators::Dummy)
    end
  end

end
