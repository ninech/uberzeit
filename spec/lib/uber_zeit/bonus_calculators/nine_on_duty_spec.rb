require 'spec_helper'

describe UberZeit::BonusCalculators::NineOnDuty do

  describe 'class' do
    subject { UberZeit::BonusCalculators::NineOnDuty }
    its(:factor) { should eq(0.1) }
    its(:description) { should be_instance_of(String) }
    its(:name) { should be_instance_of(String) }
  end

  describe 'an instance' do
    let(:pikett_bonus) { UberZeit::BonusCalculators::NineOnDuty.new(time_chunk) }
    let(:time_chunk) do
      TimeChunk.new starts: starts, ends: ends
    end

    subject { pikett_bonus }

    shared_examples :correct_calculations do
      describe 'work during non bonus times' do
        let(:starts) { '2013-02-28 13:00'.to_time }
        let(:ends) { '2013-02-28 14:00'.to_time }

        its(:result) { should eq(0) }
      end

      describe 'work started during bonus times in the morning' do
        let(:starts) { '2013-02-28 2:30'.to_time }
        let(:ends) { '2013-02-28 3:30'.to_time }

        its(:result) { should eq(6.minutes) }
      end

      describe 'work started during bonus times in the evening' do
        let(:starts) { '2013-02-28 23:30'.to_time }
        let(:ends) { '2013-02-28 23:45'.to_time }

        its(:result) { should eq(1.5.minutes) }
      end

      describe 'work spanning the bonus time start time' do
        let(:starts) { '2013-02-28 22:30'.to_time }
        let(:ends) { '2013-02-28 23:30'.to_time }

        its(:result) { should eq(3.minutes) }
      end

      describe 'work over midnight' do
        let(:starts) { '2013-08-01 23:30'.to_time }
        let(:ends) { '2013-08-02 1:30'.to_time }

        its(:result) { should eq(12.minutes) }
      end
    end

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
