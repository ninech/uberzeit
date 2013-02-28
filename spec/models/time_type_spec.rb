require 'spec_helper'

describe TimeType do
  it 'returns the name as default string' do
    time_type = FactoryGirl.create(:time_type)
    time_type.to_s == time_type.name
  end

  it 'acts as paranoid' do
    time_type = FactoryGirl.create(:time_type)
    time_type.destroy
    expect { TimeType.find(time_type.id) }.to raise_error
    expect { TimeType.with_deleted.find(time_type.id) }.to_not raise_error
  end

  it 'has a unique name' do
    time_type = FactoryGirl.create(:time_type, name: 'Work')
    FactoryGirl.build(:time_type, name: 'Work').should_not be_valid
  end
end
