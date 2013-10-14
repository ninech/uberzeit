require 'spec_helper'
require 'support/shared_examples_calculators'

describe UberZeit::BonusCalculators::NineOnDuty do

  describe 'class' do
    subject { UberZeit::BonusCalculators::NineOnDuty }
    its(:factor) { should eq(0.1) }
  end

  describe 'an instance' do
    let(:pikett_bonus) { UberZeit::BonusCalculators::NineOnDuty.new(time_chunk) }
    let(:time_chunk) do
      FactoryGirl.build(:time_entry, starts: starts, ends: ends)
    end

    subject { pikett_bonus }
    let(:factor) { 0.1 }

    context 'summer' do
      before do
        Timecop.freeze('2013-07-07 12:31')
      end

      include_examples :correct_calculations
    end

    context 'winter' do
      before do
        Timecop.freeze('2014-01-01 12:31')
      end

      include_examples :correct_calculations
    end

  end

end
