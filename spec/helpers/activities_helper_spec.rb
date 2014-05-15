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

  describe '#customer_link' do
    let(:customer_id) { 1337 }
    subject { helper.customer_link(customer_id) }

    context 'without customer_url' do
      before(:each) { UberZeit.config.customer_url = nil }

      it { should be_nil }
    end

    context 'with customer_url' do
      before(:each) { UberZeit.config.customer_url = 'https://www.nine.ch/customers/%s' }

      context 'with a deleted customer' do
        let(:customer_id) { FactoryGirl.create(:customer).tap { |c| c.delete }.id }

        it { should be_nil }
      end

      context 'with an existing customer' do
        let(:customer) { FactoryGirl.create(:customer) }
        let(:customer_id) { customer.id }

        it { should include "https://www.nine.ch/customers/#{customer.number}" }
      end
    end
  end
end
