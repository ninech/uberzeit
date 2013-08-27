require 'spec_helper'

describe API::User::Resources::Timer do
  include Warden::Test::Helpers

  let(:api_user) { FactoryGirl.create(:user, with_sheet: true) }
  let(:json) { JSON.parse(response.body) }

  before do
    login_as api_user
  end

  describe 'POST /api/timer' do
    context 'with only required attributes' do
      before do
        Timecop.freeze('2013-07-20T13:00:00+0200')
        post '/api/timer', { time_type_id: TEST_TIME_TYPES[:work].id }
      end

      subject { json }

      its(['start']) { should eq('13:00') }
      its(['date']) { should eq('2013-07-20') }
      its(['end']) { should be_nil }
      its(['duration']) { should eq('00:00') }
    end

    context 'with start time and date supplied' do
      before do
        Timecop.freeze('2013-07-20T01:00:00+0200')
        post '/api/timer', { time_type_id: TEST_TIME_TYPES[:work].id, date: '2013-07-19', start: '23:00' }
      end

      subject { json }

      its(['start']) { should eq('23:00') }
      its(['date']) { should eq('2013-07-19') }
      its(['end']) { should be_nil }
      its(['duration']) { should eq('02:00') }
    end

    describe 'validations' do
      it 'validates the presence of time type' do
        post '/api/timer', { }
        response.status.should eq(422)
        json['errors'].should include('time_type_id')
      end

      it 'makes sure that the supplied time type is not an absence time type' do
        post '/api/timer', { time_type_id: TEST_TIME_TYPES[:vacation].id }
        response.status.should eq(422)
        json['errors'].should include('time_type_id')
      end

      it 'validates the date' do
        post '/api/timer', { time_type_id: TEST_TIME_TYPES[:work].id, date: '20.07.1986' }
        response.status.should eq(422)
        json['errors'].should include('date')
      end

      it 'validates the time' do
        post '/api/timer', { time_type_id: TEST_TIME_TYPES[:work].id, start: 'Around 5 o\'clock' }
        response.status.should eq(422)
        json['errors'].should include('start')
      end
    end
  end

  describe 'PUT /api/timer' do
    context 'with an active timer' do
      let!(:timer) { FactoryGirl.create(:timer, time_sheet: api_user.current_time_sheet, start_date: '2013-07-20', start_time: '08:00') }

      before do
        Timecop.freeze('2013-07-20T13:00:00+0200')
      end

      describe 'updating of the attributes' do
        before do
          put '/api/timer', { date: '2013-07-30', start: '15:00', end: '18:00' }
        end

        subject { json }

        its(['start']) { should eq('15:00') }
        its(['end']) { should eq('18:00') }
        its(['date']) { should eq('2013-07-30') }
        its(['duration']) { should eq('03:00') }
      end

      describe 'stopping timer with end = now' do
        before do
          put '/api/timer', { end: 'now' }
        end

        subject { json }

        its(['end']) { should eq('13:00') }
        its(['duration']) { should eq('05:00') }
      end

      context 'when the end time is before start time' do
        it 'recognizes the end time is for the next day' do
          expect {
            put '/api/timer', { end: '01:00' }
            timer.reload
           }.to change(timer, :end_date).to('2013-07-21'.to_date)
        end
      end
    end

    context 'with no active timer' do
      it 'fails miserably' do
        put '/api/timer', { end: '10:00' }
        response.status.should eq(404)
      end
    end
  end

  describe 'GET /api/timer' do
    context 'with an active timer' do
      let!(:timer) { FactoryGirl.create(:timer, time_sheet: api_user.current_time_sheet, start_date: '2013-07-20', start_time: '08:00') }

      describe 'retrieval' do
        before do
          get '/api/timer'
        end

        subject { json }

        its(['start']) { should eq('08:00') }
        its(['date']) { should eq('2013-07-20') }
        its(['end']) { should be_nil }
      end
    end

    context 'with no active timer' do
      it 'fails miserably' do
        get '/api/timer'
        response.status.should eq(404)
      end
    end
  end
end
