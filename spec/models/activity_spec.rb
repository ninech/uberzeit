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
