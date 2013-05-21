require 'spec_helper'

describe SummariesHelper do
  describe '#types_to_tooltip_table' do
    let(:time_type_time_hash) { Hash[TEST_TIME_TYPES[:work], 4.5.hours, TEST_TIME_TYPES[:vacation], 2.work_days] }

    subject { helper.types_to_tooltip_table(time_type_time_hash ) }

    it { should have_selector('div', text: '2 d') }
    it { should have_selector('div', text: '04:30') }
  end

  describe '#format_work_days' do
    subject { helper.format_work_days(duration) }

    context 'positive duration' do
      let(:duration) { 2.5.work_days }

      it { should have_selector('span', text: '2.5') }
    end

    context 'negative duration' do
      let(:duration) { -3.5.work_days }

      it { should have_selector('span', text: '-3.5') }
    end
  end

  describe '#format_hours' do
    subject { helper.format_hours(duration) }

    context 'positive duration' do
      let(:duration) { 3.5.hours }

      it { should have_selector('span', text: '03:30') }
    end

    context 'negative duration' do
      let(:duration) { -1.5.hours }

      it { should have_selector('span', text: '-01:30') }
    end
  end
end
