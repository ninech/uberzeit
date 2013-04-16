require 'spec_helper'

describe Absence do
  it 'has a valid factory' do
    FactoryGirl.create(:absence).should be_valid
  end

  it 'acts as paranoid' do
    entry = FactoryGirl.create(:absence)
    entry.destroy
    expect { Absence.find(entry.id) }.to raise_error
    expect { Absence.with_deleted.find(entry.id) }.to_not raise_error
  end

  it 'makes sure that the end date is not before the start date' do
    entry = FactoryGirl.build(:absence, start_date: '2013-01-03', end_date: '2013-01-02')
    entry.should_not be_valid
  end

  it 'returns the duration' do
    entry = FactoryGirl.build(:absence, start_date: '2013-01-03', end_date: '2013-01-03')
    entry.duration.should eq(1.day)
  end

  it 'returns the entries sorted by start date' do
    # create the newer entry first
    entry1 = FactoryGirl.create(:absence, start_date: '2013-01-04', end_date: '2013-01-04')
    entry2 = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-03')

    Absence.all.should eq([entry2,entry1])
  end

  it 'tells you whether or not it\'s a whole day entry' do
    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04')
    entry.whole_day?.should be_true

    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true)
    entry.whole_day?.should be_false

    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', second_half_day: true)
    entry.whole_day?.should be_false

    entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true, second_half_day: true)
    entry.whole_day?.should be_true
  end

  # it 'provides the ability to convert the entries to chunks' do
  #   entry = FactoryGirl.create(:absence, start_date: '2013-01-03', end_date: '2013-01-04', first_half_day: true)
  #   chunks = Absence.between('2013-01-03'.to_date..'2013-01-03'.to_date).to_chunks
  #   chunks.length.should eq(2)
  #   chunks.first.duration.should eq(12.hours)
  # end
  #

  describe '#daypart' do
    let(:absence) { Absence.new }
    it 'allows setting a whole day' do
      absence.daypart = :whole_day
      absence.whole_day?.should be_true
      absence.first_half_day?.should be_false
      absence.second_half_day?.should be_false
      absence.daypart.should eq(:whole_day)
    end
    it 'allows setting the first half of a day' do
      absence.daypart = :first_half_day
      absence.whole_day?.should be_false
      absence.first_half_day?.should be_true
      absence.second_half_day?.should be_false
      absence.daypart.should eq(:first_half_day)
    end
    it 'allows setting the second half of a day' do
      absence.daypart = :second_half_day
      absence.whole_day?.should be_false
      absence.first_half_day?.should be_false
      absence.second_half_day?.should be_true
      absence.daypart.should eq(:second_half_day)
    end
  end

  context 'for multiple entries' do
    before do
      @entry1 = FactoryGirl.create(:absence, time_type: :work, start_date: '2013-01-23', end_date: '2013-01-30', first_half_day: true)
      @entry2 = FactoryGirl.create(:absence, time_type: :compensation, start_date: '2013-01-23', end_date: '2013-01-23')
      @entry3 = FactoryGirl.create(:absence, time_type: :work, start_date: '2013-01-23', end_date: '2013-01-24', second_half_day: true)
      @entry4 = FactoryGirl.create(:absence, time_type: :work, start_date: '2013-01-24', end_date: '2013-01-24')
    end

    # it 'returns entries between two dates' do
    #   Absence.between('2013-01-23'.to_date..'2013-01-30'.to_date).should =~ [@entry1,@entry2,@entry3,@entry4]
    #   Absence.between('2013-01-23'.to_date..'2013-01-24'.to_date).should =~ [@entry1,@entry2,@entry3,@entry4]
    #   Absence.between('2013-01-24'.to_date..'2013-01-27'.to_date).should =~ [@entry1,@entry3,@entry4]
    #   Absence.between('2013-01-25'.to_date..'2013-01-26'.to_date).should =~ [@entry1]
    # end
  end
end
