require 'spec_helper'


describe ReportsHelper do
  describe '#time_per_time_type_to_tooltip_table' do
    before do
      helper.should_receive(:color_for_duration).twice.and_return('color1')
      helper.should_receive(:display_in_hours).once.and_return('13:37')
    end

    let(:time_type_time_hash) do
      { TEST_TIME_TYPES[:work] => 4.5.hours, TEST_TIME_TYPES[:vacation] => 2.work_days }
    end

    subject { helper.time_per_time_type_to_tooltip_table(time_type_time_hash ) }

    it { should have_selector('div', text: '2 d') }
    it { should have_selector('div', text: '13:37') }
  end

  describe '#format_work_days' do
    before do
      helper.should_receive(:color_for_duration).once.and_return('color1')
    end

    subject { helper.format_work_days(duration) }

    context 'positive duration' do
      let(:duration) { 2.5 }

      it { should have_selector('span', text: '2.5') }
    end

    context 'negative duration' do
      let(:duration) { -3.5 }

      it { should have_selector('span', text: '-3.5') }
    end
  end

  describe '#format_hours' do
    before do
      helper.should_receive(:color_for_duration).once.and_return('color1')
      helper.should_receive(:display_in_hours).once.and_return('13:37')
    end

    subject { helper.format_hours(duration) }

    context 'positive duration' do
      let(:duration) { 3.5.hours }

      it { should have_selector('span', text: '13:37') }
    end

    context 'negative duration' do
      let(:duration) { -1.5.hours }

      it { should have_selector('span', text: '13:37') }
    end
  end
end
