require 'spec_helper'

describe ActivityType do
  describe 'validations' do
    let(:activity_type) { ActivityType.new }

    it 'it does not accept a blank name' do
      activity_type.name = ''
      activity_type.should_not be_valid
      activity_type.should have(1).errors_on(:name)
    end
  end
end
