require 'spec_helper'

describe TimeSheetsHelper do
  describe '#format_duration' do
    it 'formats positive durations' do
      helper.format_duration(8.5.hours).should eq("08:30")
    end

    it 'formats negative durations' do
      helper.format_duration(-2.5.hours).should eq("-02:30")
    end
  end
end
