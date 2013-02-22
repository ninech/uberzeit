require 'spec_helper'

describe Employment do
  it 'has a valid factory' do
    FactoryGirl.create(:employment).should be_valid
  end

  it 'acts as paranoid' do
    sheet = FactoryGirl.create(:employment)
    sheet.destroy
    expect { Employment.find(sheet.id) }.to raise_error
    expect { Employment.with_deleted.find(sheet.id) }.to_not raise_error
  end
end
