# encoding: utf-8
require 'spec_helper'

describe 'having fun with absences' do
  include RequestHelpers

  let(:user) { FactoryGirl.create(:admin) }

  before do
    Timecop.travel('2013-04-22 12:00:00 +0200')
    login user
  end

  it 'adds an absence', js: true do
    visit user_absences_path(user)
    click_on 'Absenz hinzufügen'
    select 'test_vacation', from: 'absence_time_type_id'
    select 'Vormittags', from: 'absence_daypart'
    click_on 'Absenz erstellen'
    find('.event-container').click
    page.should have_content('test_vacation')
    page.should have_content('22.04.2013')
  end

  it 'updates an absence', js: true do
    absence = FactoryGirl.create(:absence, start_date: '2013-01-08', end_date: '2013-01-08', time_type: :vacation, user: user)
    absence.recurring_schedule.update_attribute(:ends_date, '2013-01-08') # explicitly set recurring end date so date picker preselects correct month

    visit user_absences_path(user)

    find('.event-container').click
    click_on 'Bearbeiten'

    find('#absence_recurring_schedule_attributes_active').click
    fill_in 'absence[recurring_schedule_attributes][weekly_repeat_interval]', with: 2


    find('#absence_recurring_schedule_attributes_ends_date').click
    find('.picker.picker--focused.picker--opened').find('div.picker__day', text: '27').click

    click_on 'Absenz aktualisieren'

    find('table', text: 'Januar').find('.event-container', text: '8').click
    page.should have_content('test_vacation')
    page.should have_content('Wiederholung: Alle 2 Wochen bis zum 27.01.2013')
  end

  it 'deletes an absence', js: true do
    FactoryGirl.create(:absence, start_date: '2013-04-08', end_date: '2013-04-08', time_type: :vacation, user: user)

    visit user_absences_path(user)
    find('.event-container').click
    click_on 'Bearbeiten'
    find('form').find('a', text: 'Löschen').click

    first('.event-container').should be_nil
  end
end
