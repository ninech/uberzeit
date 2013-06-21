require 'spec_helper'

describe ActivityType do
  it 'has a valid factory' do
    FactoryGirl.build(:activity_type).should be_valid
  end

  it 'acts as paranoid' do
    entry = FactoryGirl.create(:activity_type)
    entry.destroy
    expect { ActivityType.find(entry.id) }.to raise_error
    expect { ActivityType.with_deleted.find(entry.id) }.to_not raise_error
  end

  describe 'validations' do
    let(:activity_type) { ActivityType.new }

    it 'it does not accept a blank name' do
      activity_type.name = ''
      activity_type.should_not be_valid
      activity_type.should have(1).errors_on(:name)
    end
  end
end
