require 'spec_helper'

describe TimeSheetsController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:sheet) { user.time_sheets.first }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :show, id: sheet, date: Date.today
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in user
    end

    describe 'GET "show"' do
      it 'assigns @time_sheet' do
        get :show, id: sheet, date: Date.today
        assigns(:time_sheet).should eq(sheet)
      end

      it 'renders the :show template' do
        get :show, id: sheet, date: Date.today
        response.should render_template :show
      end
    end

    describe 'GET "summary_for_date"' do
      it 'assigns the correct instance variables' do
        get :summary_for_date, id: sheet, date: Date.today, format: :javascript
        assigns(:total).should_not be_nil
        assigns(:timer_duration_for_day).should_not be_nil
        assigns(:timer_duration_since_start).should_not be_nil
        assigns(:bonus).should_not be_nil
        assigns(:week_total).should_not be_nil
      end

      it 'limits the timer duration to the range of the requested day' do
        FactoryGirl.create(:time_entry, time_sheet: sheet, starts: '2013-07-20 18:00:00 +0200', ends: nil)

        Timecop.freeze('2013-07-21 12:00:00 +0200'.to_time)
        get :summary_for_date, id: sheet, date: '2013-07-20'.to_date, format: :javascript
        assigns(:timer_duration_for_day).should eq(6.hours)
        assigns(:timer_duration_since_start).should eq(18.hours)
      end

      it 'adds the timer duration to the total' do
        FactoryGirl.create(:time_entry, time_sheet: sheet, starts: '2013-07-21 09:00:00 +0200', ends: '2013-07-21 11:00:00 +0200')
        FactoryGirl.create(:time_entry, time_sheet: sheet, starts: '2013-07-21 11:00:00 +0200', ends: nil)

        Timecop.freeze('2013-07-21 12:00:00 +0200'.to_time)
        get :summary_for_date,  id: sheet, date: '2013-07-21'.to_date, format: :javascript
        assigns(:total).should eq(3.hours)
      end

    end
  end
end
