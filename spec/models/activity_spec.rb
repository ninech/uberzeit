# == Schema Information
#
# Table name: activities
#
#  id                :integer          not null, primary key
#  activity_type_id  :integer
#  user_id           :integer
#  date              :date
#  duration          :integer
#  description       :text
#  customer_id       :integer
#  project_id        :integer
#  redmine_ticket_id :integer
#  otrs_ticket_id    :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#  billable          :boolean          default(FALSE), not null
#  reviewed          :boolean          default(FALSE), not null
#  billed            :boolean          default(FALSE), not null
#

require 'spec_helper'

describe Activity do

  it 'has a valid factory' do
    FactoryGirl.create(:activity).should be_valid
  end

  it 'acts as paranoid' do
    activity = FactoryGirl.create(:activity)
    activity.destroy
    expect { Activity.find(activity.id) }.to raise_error
    expect { Activity.with_deleted.find(activity.id) }.to_not raise_error
  end

  describe 'validations' do
    let(:activity) { FactoryGirl.create(:activity) }

    it 'it does not accept a duration of zero' do
      activity.duration = 0
      activity.should_not be_valid
      activity.should have(1).errors_on(:duration)
    end

    it 'requires a customer associated' do
      activity.customer_id = nil
      activity.should_not be_valid
      activity.should have(1).errors_on(:customer_id)
    end

    it 'requires an existing customer associated' do
      activity.customer_id = 999999999
      activity.should_not be_valid
      activity.should have(1).errors_on(:customer_id)
    end
  end

end
