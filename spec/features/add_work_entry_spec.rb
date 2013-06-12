require 'spec_helper'

describe 'adding time entries' do
  include RequestHelpers

  let(:user) { FactoryGirl.create(:user) }
  let(:time_sheet) { user.current_time_sheet }

  before do
    Timecop.travel('2013-04-22 12:00:00 +0200')
    login user
  end

  it 'starts a timer', js: true do
    visit time_sheet_path(time_sheet)
    click_on 'Zeit jetzt eintragen'
    click_on 'Speichern'
    page.should have_content('12:00')
    page.should have_content('Stop')
  end

  it 'creates a time entry', js: true do
    visit time_sheet_path(time_sheet)
    click_on 'Zeit jetzt eintragen'
    fill_in 'Von', with: '10'
    fill_in 'Bis', with:  '1130'
    select 'test_work', from: 'time_entry_time_type_id'
    find_field('Von').value.should eq('10:00')
    find_field('Bis').value.should eq('11:30')
    page.should have_content('01:30')
    click_on 'Speichern'
    page.should have_content(/10:00 . 11:30/)
    page.should_not have_content('Stop')
    page.should have_content('Total 01:30')
  end
end
