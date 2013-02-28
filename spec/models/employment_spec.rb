require 'spec_helper'

describe Employment do
  it 'has a valid factory' do
    FactoryGirl.create(:employment).should be_valid
  end

  it 'cannot be deleted if it is the last one for the user' do
    employment = FactoryGirl.create(:employment)
    employment.destroy.should be_false
  end

  it 'makes sure the workload is between 1 and 100' do
    FactoryGirl.build(:employment, workload: 0).should_not be_valid
    FactoryGirl.build(:employment, workload: 150).should_not be_valid
    FactoryGirl.build(:employment, workload: -5).should_not be_valid
    FactoryGirl.build(:employment, workload: 50).should be_valid
  end

  context 'for multiple employments per user' do
    before do
      # create tricky employment scheme 
      @user = FactoryGirl.create(:user, with_employment: false)
      @user.employments << FactoryGirl.create(:employment, start_date: '2012-06-06', end_date: '2013-01-01', workload: 100)
      @user.employments << FactoryGirl.create(:employment, start_date: '2013-01-01', end_date: '2013-02-11', workload: 50) # monday!
      @user.employments << FactoryGirl.create(:employment, start_date: '2013-02-11', end_date: '2013-02-12', workload: 80) # 1 day test
      @user.employments << FactoryGirl.create(:employment, start_date: '2013-02-12', end_date: nil, workload: 40)
    end

    it 'can be deleted if there are more than one employments for the user' do
      @user.employments.last.destroy.should be_true
    end

    it 'returns the employments between two dates' do
      # try to select border-line instances
      @user.employments.between('2013-01-01'.to_date, '2013-02-11'.to_date).length.should eq(1)
      @user.employments.between('2013-01-01'.to_date, '2013-02-12'.to_date).length.should eq(2)
      @user.employments.between('2013-02-11'.to_date, '2013-02-12'.to_date).length.should eq(1)
      @user.employments.between('2012-01-01'.to_date, '2013-01-01'.to_date).length.should eq(1)
    end

    it 'returns the employment for a specific date' do
      @user.employments.on('2013-02-11'.to_date).workload.should eq(80)
      @user.employments.on('2013-02-12'.to_date).workload.should eq(40)
    end

    it 'resolves conflicts between two open ended employments' do
      open_ended = @user.employments.find { |employment| employment.open_ended? }
      @user.employments << FactoryGirl.create(:employment, start_date: '2013-06-12', end_date: nil, workload: 20)
      open_ended.reload.open_ended?.should be_false
    end
  end
end
