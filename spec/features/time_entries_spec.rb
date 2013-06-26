# encoding: utf-8
require 'spec_helper'

describe 'messing around with time entries' do
  include RequestHelpers

  let(:user) { FactoryGirl.create(:user) }
  let(:time_sheet) { user.current_time_sheet }

  before do
    Timecop.travel('2013-04-22 12:00:00 +0200')
    login user
  end

  describe 'timers' do
    it 'starts a timer', js: true do
      visit time_sheet_path(time_sheet)
      click_on 'Zeit jetzt eintragen'
      click_on 'Timer starten'
      page.should have_content('12:00')
      page.should have_content('Stop')
    end

    it 'stops a timer', js: true do
      visit time_sheet_path(time_sheet)
      click_on 'Zeit hinzufügen'
      click_on 'Timer starten'
      page.should have_content('12:00')
      page.should have_content('Stop')
      Timecop.travel('2013-04-22 15:30:00 +0200')
      visit time_sheet_path(time_sheet)
      click_on 'Stop'
      page.should have_content(/12:00 . 15:30/)
      page.should_not have_content('Stop')
    end
  end

  describe 'time entries' do
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

    it 'creates a time entry on another date', js: true do
      visit time_sheet_path(time_sheet)
      click_on 'Zeit jetzt eintragen'
      fill_in 'Von', with: '17:00'
      fill_in 'Bis', with: '22:00'
      find('#time_entry_start_date').click
      find('form#new_time_entry div.picker__day', text: '15').click
      click_on 'Speichern'
      page.should have_content('15. Apr')
      page.should have_content('Total 05:00')
    end

    it 'updates an existing time entry', js: true do
      FactoryGirl.create(:time_entry, starts: '2013-04-22 17:00:00 +0200', ends: '2013-04-22 18:00 +0200', time_sheet: time_sheet)
      visit time_sheet_path(time_sheet)
      page.should have_content('Total 01:00')
      find('li', text: /17:00 . 18:00/).hover
      find('.icon-edit').click
      fill_in 'Von', with: '23:00'
      fill_in 'Bis', with: '01:00'
      find('#time_entry_start_date').click
      find('div#time-modal form div.picker__day', text: '20').click
      click_on 'Speichern'
      page.should have_content('20. Apr')
      page.should have_content('Total 01:00')
    end

    it 'deletes a time entry', js: true do
      FactoryGirl.create(:time_entry, starts: '2013-04-22 17:00:00 +0200', ends: '2013-04-22 18:00 +0200', time_sheet: time_sheet)
      visit time_sheet_path(time_sheet)
      find('li', text: /17:00 . 18:00/).hover
      find('.icon-edit').click
      click_link 'Löschen'

      page.should have_content('Total 00:00')
      page.should_not have_content(/17:00 - 18:00/)
    end
  end
end
