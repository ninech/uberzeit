require 'spec_helper'

describe API::Resources::Activities do
  include ApiHelpers

  let(:api_user) { FactoryGirl.create(:user) }
  let(:parsed_json) { JSON.parse(response.body) }
  let(:activity_type) { FactoryGirl.create(:activity_type) }
  let(:required_attributes) do
    { activity_type_id: activity_type.id, date: '2013-07-20', duration: 7200 }
  end

  shared_examples 'an activity' do
    its(['id']) { should be_present }
    its(['activity_type_id']) { should_not be_present }
    its(['activity_type']) { should be_present }
    its(['date']) { should be_present }
    its(['duration']) { should be_present }
    its(['user_id']) { should be_present }
    its(['user']) { should_not be_present }
  end

  describe 'GET /api/activities' do
    let!(:activity) { FactoryGirl.create(:activity, user: api_user) }
    let!(:another_user) { FactoryGirl.create(:user) }
    let!(:activity_of_another_user) { FactoryGirl.create(:activity, user: another_user) }

    before do
      auth_get '/api/activities'
    end

    it 'returns all activities' do
      parsed_json.should have(2).items
    end

    it_behaves_like 'an activity' do
      subject { parsed_json.first }
    end

    describe 'GET /api/activities?embed=user' do
      before do
        auth_get '/api/activities?embed=user'
      end

      subject { parsed_json.first['user'] }

      its(['id']) { should be_present }
      its(['name']) { should be_present }
      its(['uid']) { should_not be_present }
      its(['authentication_token']) { should_not be_present }
      its(['birthday']) { should_not be_present }
    end

    describe 'GET /api/activities?embed=babo' do
      it 'validates the embed parameter' do
        auth_get '/api/activities?embed=babo'
        response.status.should eq(422)
        parsed_json['errors'].should include('embed')
      end
    end
  end

  describe 'POST /api/activities' do
    context 'with the required attributes' do
      before do
        auth_post '/api/activities', required_attributes
      end

      subject { parsed_json }

      its(['id']) { should eq(Activity.last.id) }
      its(['date']) { '2013-07-20' }
      its(['duration']) { should eq(7200) }

      it 'embeds the activity type' do
        subject['activity_type']['id'].should eq(activity_type.id)
        subject['activity_type']['name'].should eq(activity_type.name)
      end

      it_behaves_like 'an activity'

      it 'assigns the activity to the current user' do
        Activity.last.user.should eq(api_user)
      end
    end

    context 'with optional attributes' do
      before do
        auth_post '/api/activities', required_attributes.merge(redmine_ticket_id: 42,
                                                               customer_id: 22,
                                                               project_id: 1,
                                                               otrs_ticket_id: 137)
      end

      subject { parsed_json }

      its(['redmine_ticket_id']) { should eq(42) }
      its(['customer_id']) { should eq(22) }
      its(['project_id']) { should eq(1) }
      its(['otrs_ticket_id']) { should eq(137) }
    end

    describe 'duration' do
      it 'does not accept hh:mm' do
        auth_post '/api/activities', required_attributes.merge(duration: '03:15')
        response.status.should eq(422)
      end
    end
  end

  describe 'GET /api/activities/redmine_ticket/:redmine_ticket_id' do
    let!(:activity) { FactoryGirl.create(:activity, user: api_user, redmine_ticket_id: 42) }
    let!(:another_activity) { FactoryGirl.create(:activity, user: api_user, redmine_ticket_id: 1337) }

    before do
      auth_get '/api/activities/redmine_ticket/42'
    end

    it 'returns a list of activities with the given redmine ticket' do
      parsed_json.should have(1).items
    end

    it_behaves_like 'an activity' do
      subject { parsed_json.first }
    end
  end
end
