require 'spec_helper'

describe TimeSheet do
  it 'has a valid factory' do
    FactoryGirl.create(:time_sheet).should be_valid
  end

  it 'acts as paranoid' do
    sheet = FactoryGirl.create(:time_sheet)
    sheet.destroy
    expect { TimeSheet.find(sheet.id) }.to raise_error
    expect { TimeSheet.with_deleted.find(sheet.id) }.to_not raise_error
  end
end