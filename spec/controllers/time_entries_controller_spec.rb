# encoding: UTF-8

require 'spec_helper'

describe TimeEntriesController do
  render_views

  context 'for non-signed in users' do
    it 'redirects to login' do
      user = FactoryGirl.create(:user)
      get :new, user_id: user.id
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do
    let(:user) { FactoryGirl.create(:user) }
    let(:time_entry) { FactoryGirl.create(:time_entry, user: user) }

    before do
      test_sign_in user
    end

    describe 'GET "index"' do
      let(:date) { '2013-01-01'.to_date }
      let!(:time_entry_late) { FactoryGirl.create(:time_entry, start_date: date, end_date: date, user: user, start_time: '15:00', end_time: '16:00') }
      let!(:time_entry_early) { FactoryGirl.create(:time_entry, start_date: date, end_date: date, user: user, start_time: '10:00', end_time: '12:00') }

      before do
        get :index, user_id: user.id, date: date
      end

      subject { response }

      it 'assigns sorted @time_spans_of_time_entries' do
        assigns(:time_spans_of_time_entries).should eq(time_entry_early.time_spans + time_entry_late.time_spans)
      end

      it { should render_template(:index) }
      it { assigns(:weekdays).should be_instance_of(Array)}
    end

    describe 'GET "new"' do
      it 'sets the start date if provided' do
        Timecop.freeze('2013-07-22')
        get :new, user_id: user, date: '2013-07-20'
        assigns(:time_entry).start_date.should eq('2013-07-20'.to_date)
      end
    end

    describe 'PUT "update"' do
      before do
        time_entry = FactoryGirl.create(:time_entry, user: user, start_date: '2013-02-01', end_date: '2013-02-01', start_time: '06:00', end_time: '09:00:00')
      end

      context 'with valid attributes' do
        it 'changes time_entry\'s attributes' do
          put :update, id: time_entry, user_id: time_entry.user, time_entry: {start_date: '2013-02-02', start_time: '11:00', end_time: '12:00'}
          time_entry.reload
          time_entry.starts.should eq('2013-02-02 11:00 +0100'.to_time)
          time_entry.ends.should eq('2013-02-02 12:00 +0100'.to_time)
        end

        it 'redirects to the sheet overview' do
          put :update, id: time_entry, user_id: time_entry.user, time_entry: FactoryGirl.attributes_for(:time_entry)
          response.body.should redirect_to(user_time_entries_path(user))
        end

        it 'updates start and end date of the corresponding time entry' do
          put :update, id: time_entry, user_id: time_entry.user, time_entry: {start_date: '2013-02-05', start_time: '23:00', end_time: '01:00'}
          time_entry.reload
          time_entry.starts.should eq("2013-02-05 23:00 +0100".to_time)
          time_entry.ends.should eq("2013-02-06 01:00 +0100".to_time)
        end

        it 'does not set the end date to tomorrow if the time is the same' do
          put :update, id: time_entry, user_id: time_entry.user, time_entry: {start_date: '2013-02-05', start_time: '23:00', end_time: '23:00'}
          time_entry.reload
          time_entry.starts.should eq("2013-02-05 23:00 +0100".to_time)
          time_entry.ends.should eq("2013-02-05 23:00 +0100".to_time)
        end

        it 'will restart a timer when the end time is empty' do
          expect {
            put :update, id: time_entry, user_id: time_entry.user, time_entry: {start_date: '2013/02/05', start_time: '23:00', end_time: ''}
            time_entry.reload
          }.to change(time_entry, :timer?).from(false).to(true)
        end
      end

      context 'with invalid attributes' do
        it 're-renders the :edit template' do
          put :update, id: time_entry, user_id: time_entry.user, time_entry: FactoryGirl.attributes_for(:time_entry, start_time: '')
          response.body.should =~ /muss ausgefüllt werden/
        end
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        let(:time_type) { TEST_TIME_TYPES[:work] }

        it 'creates a new single entry' do
          expect do
            post :create, user_id: user.id, time_entry: FactoryGirl.attributes_for(:time_entry, time_type_id: time_type)
          end.to change(TimeEntry,:count).by(1)
        end

        it 'returns empty json (no errors)' do
          post :create, user_id: user.id, time_entry: FactoryGirl.attributes_for(:time_entry, time_type_id: time_type)
          response.body.should redirect_to(user_time_entries_path(user))
        end

        it 'creates a timer on the selected date' do
          Timecop.freeze('2013-07-22')
          post :create, user_id: user.id, time_entry: FactoryGirl.attributes_for(:time_entry, time_type_id: time_type, start_time: '09:00')
          assigns(:time_entry).start_date.should eq('2013-07-22'.to_date)
        end

        it 'understands a time range which spans over midnight' do
          Timecop.freeze('2013-02-02 16:00 +0100')
          post :create, user_id: user.id, time_entry: FactoryGirl.attributes_for(:time_entry, time_type_id: time_type, start_time: '23:00', end_time: '01:00', end_date: nil)
          assigns(:time_entry).start_date.should eq('2013-02-02'.to_date)
          assigns(:time_entry).end_date.should eq('2013-02-03'.to_date)
          assigns(:time_entry).duration.should eq(2.hours)
        end

        it 'creates the entry for the selected user' do
          user.add_role :admin
          user2 = FactoryGirl.create(:user)
          post :create, user_id: user2.id, time_entry: FactoryGirl.attributes_for(:time_entry, time_type_id: time_type)
          assigns(:time_entry).user_id.should eq(user2.id)
        end
      end

      context 'with invalid attributes' do
        it 'does not save the new single entry' do
          expect { post :create, user_id: user.id, time_entry: FactoryGirl.attributes_for(:invalid_time_entry) }.to_not change(TimeEntry,:count)
        end

        it 'returns json errors' do
          post :create, user_id: user.id, time_entry: FactoryGirl.attributes_for(:time_entry, start_time: '')
          response.body.should =~ /muss ausgefüllt werden/
        end
      end
    end

    describe 'DELETE "destroy"' do

      it 'deletes the entry' do
        time_entry
        expect { delete :destroy, id: time_entry, user_id: time_entry.user }.to change(TimeEntry,:count).by(-1)
      end
    end

    describe 'GET "summary_for_date"' do
      it 'assigns the correct instance variables' do
        get :summary_for_date, user_id: user.id, date: Date.today, format: :javascript
        assigns(:total).should_not be_nil
        assigns(:timer_duration_for_day).should_not be_nil
        assigns(:timer_duration_since_start).should_not be_nil
        assigns(:bonus).should_not be_nil
        assigns(:week_total).should_not be_nil
      end

      it 'limits the timer duration to the range of the requested day' do
        FactoryGirl.create(:time_entry, user: user, starts: '2013-07-20 18:00:00 +0200', ends: nil)

        Timecop.freeze('2013-07-21 12:00:00 +0200'.to_time)
        get :summary_for_date, user_id: user.id, date: '2013-07-20'.to_date, format: :javascript
        assigns(:timer_duration_for_day).should eq(6.hours)
        assigns(:timer_duration_since_start).should eq(18.hours)
      end

      it 'adds the timer duration to the total' do
        FactoryGirl.create(:time_entry, user: user, starts: '2013-07-21 09:00:00 +0200', ends: '2013-07-21 11:00:00 +0200')
        FactoryGirl.create(:time_entry, user: user, starts: '2013-07-21 11:00:00 +0200', ends: nil)

        Timecop.freeze('2013-07-21 12:00:00 +0200')
        get :summary_for_date, user_id: user.id, date: '2013-07-21', format: :javascript
        assigns(:total).should eq(3.hours)
      end
    end

    describe 'PUT "stop_timer"' do
      let!(:timer) { FactoryGirl.create(:timer, user: user) }

      it 'stops the running timer of this day' do
        expect { put :stop_timer, user_id: user.id, date: timer.starts }.to change { user.time_entries.timers_only.count }
      end
    end
  end
end
