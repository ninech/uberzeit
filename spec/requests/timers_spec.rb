require 'spec_helper'

describe UberZeit::API do
  let(:user) { FactoryGirl.create(:user, uid: 'testuser', with_sheet: true) }
  let(:parsed_json) { JSON.parse(response.body) }

  describe 'v1' do
    def headers
      {
        'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(user.uid, 'apiaccess42'),
        'HTTP_ACCEPT' => 'application/vnd.nine.ch-v1+json'
      }
    end

    def auth_post(route, params = {})
      post route, params, headers
    end

    describe 'POST /api/timers' do
      context 'with only required attributes' do
        before do
          Timecop.freeze('2013-07-20T13:00:00+0200')
          auth_post '/api/timers', { time_type_id: TEST_TIME_TYPES[:work].id }
        end

        subject { parsed_json }

        its(['starts']) { should eq('2013-07-20T13:00:00+02:00') }
        its(['id']) { should eq(TimeEntry.last.id) }
      end

      context 'with start time and date supplied' do
        before do
          Timecop.freeze('2013-07-20')
          auth_post '/api/timers', { time_type_id: TEST_TIME_TYPES[:work].id, start_date: '2013-07-24', start_time: '09:00' }
        end

        subject { parsed_json }

        its(['starts']) { should eq('2013-07-24T09:00:00+02:00') }
      end

      describe 'validations' do
        it 'validates the presence of time type' do
          auth_post '/api/timers', {}
          response.status.should eq(400)
          parsed_json['param'].should eq('time_type_id')
        end

        it 'makes sure that the supplied time type is not an absence time type' do
          auth_post '/api/timers', { time_type_id: TEST_TIME_TYPES[:vacation].id }
          response.status.should eq(400)
          parsed_json['param'].should eq('time_type_id')
        end

        it 'validates the date' do
          auth_post '/api/timers', { time_type_id: TEST_TIME_TYPES[:work].id, start_date: '20.07.1986' }
          response.status.should eq(400)
          parsed_json['param'].should eq('start_date')
        end

        it 'validates the time' do
          auth_post '/api/timers', { time_type_id: TEST_TIME_TYPES[:work].id, start_time: 'Around 5 o\'clock' }
          response.status.should eq(400)
          parsed_json['param'].should eq('start_time')
        end
      end

    end
  end
end
