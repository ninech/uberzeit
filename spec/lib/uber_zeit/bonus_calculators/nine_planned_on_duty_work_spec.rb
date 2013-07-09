require 'spec_helper'
require 'support/shared_examples_calculators'

describe UberZeit::BonusCalculators::NinePlannedOnDutyWork do

  describe 'class' do
    subject { UberZeit::BonusCalculators::NinePlannedOnDutyWork }
    its(:factor) { should eq(0.25) }
    its(:description) { should be_instance_of(String) }
    its(:name) { should be_instance_of(String) }
  end

  describe 'an instance' do
    let(:pikett_bonus) { UberZeit::BonusCalculators::NinePlannedOnDutyWork.new(time_chunk) }
    let(:time_chunk) do
      TimeChunk.new starts: starts, ends: ends
    end

    subject { pikett_bonus }
    let(:factor) { 0.25 }

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

