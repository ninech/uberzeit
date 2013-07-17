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
#

require 'spec_helper'

describe Activity do

  describe 'validations' do
    let(:activity) { Activity.new }

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
  end

end
