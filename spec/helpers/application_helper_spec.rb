require 'spec_helper'

describe ApplicationHelper do
  describe '#display_in_hours' do
    it 'formats positive durations' do
      helper.display_in_hours(8.5.hours).should eq("08:30")
    end

    it 'formats negative durations' do
      helper.display_in_hours(-2.5.hours).should eq("-02:30")
      helper.display_in_hours(-0.5.hours).should eq("-00:30")
    end

    it 'rounds minutes up' do
      helper.display_in_hours(2.hours + 1.2.minutes).should eq("02:02")
    end
  end
end
