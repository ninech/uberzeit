require 'spec_helper'

describe Activity do

  describe 'validations' do
    let(:activity) { Activity.new }

    it 'it does not accept a duration of zero' do
      activity.duration = 0
      activity.valid?.should be_false
      activity.should have(1).errors_on(:duration)
    end
  end

end
