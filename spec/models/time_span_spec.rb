# == Schema Information
#
# Table name: time_spans
#
#  id                    :integer          not null, primary key
#  date                  :date
#  duration              :integer
#  duration_in_work_days :float
#  duration_bonus        :integer
#  user_id               :integer
#  time_type_id          :integer
#  time_spanable_id      :integer
#  time_spanable_type    :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

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

    it 'calculates duration correctly' do
      subject.duration_in_work_days = 1
      subject.duration.should eq(8.5.hours)
    end
  end

  describe '#credited_duration=' do
    it 'calculates credited_duration_in_work_days' do
      expect { subject.credited_duration = 1.5.work_days }.to change { subject.credited_duration_in_work_days }
    end

    it 'calculates credited_duration_in_work_days correctly' do
      subject.credited_duration = 4.25.hours
      subject.credited_duration_in_work_days.should eq(0.5)
    end
  end
  describe '#credited_duration_in_work_days=' do
    it 'calculates credited_duration' do
      expect { subject.credited_duration_in_work_days = 1 }.to change { subject.credited_duration }
    end

    it 'calculates credited_duration correctly' do
      subject.credited_duration_in_work_days = 1
      subject.credited_duration.should eq(8.5.hours)
    end
  end

end
