require 'spec_helper'

describe TimeSpan do
  subject { TimeSpan.new }

  describe '#duration=' do
    it 'calculates duration_in_work_days' do
      expect { subject.duration = 1.5.days }.to change { subject.duration_in_work_days }
    end

    it 'calculates duration_in_work_days correctly' do
      subject.duration = 4.25.hours
      subject.duration_in_work_days.should eq(0.5)
    end
  end

  describe '#duration_in_work_days=' do
    it 'calculates duration' do
      expect { subject.duration_in_work_days = 1 }.to change { subject.duration }
    end

    it 'calculates duration_in_work_days correctly' do
      subject.duration_in_work_days = 1
      subject.duration.should eq(8.5.hours)
    end
  end

end
