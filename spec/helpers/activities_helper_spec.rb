require 'spec_helper'

describe ActivitiesHelper do
  describe '#activity_source_information' do
    subject { helper.activity_source_information(activity) }

    before do
      helper.stub(:t) { |source, info| "#{source}: #{info[:ticket_url]}" }
    end

    context 'activity without redmine or otrs link' do
      let(:activity) { FactoryGirl.create(:activity, redmine_ticket_id: nil, otrs_ticket_id: nil) }
      it { should eq '' }
    end

    context 'activity with redmine link' do
      let(:activity) { FactoryGirl.create(:activity, redmine_ticket_id: 1337, otrs_ticket_id: nil) }
      it { should eq '.redmine: <a href="https://redmine.yolo/issues/1337">#1337</a>' }
    end

    context 'activity with redmine and otrs link' do
      let(:activity) { FactoryGirl.create(:activity, redmine_ticket_id: 1337, otrs_ticket_id: 42) }
      it { should eq '.otrs: <a href="https://otrs.howdoyouturnthison/otrs/index.pl?Action=AgentTicketZoom&amp;TicketNumber=42">#42</a> und .redmine: <a href="https://redmine.yolo/issues/1337">#1337</a>' }
    end
  end
end
