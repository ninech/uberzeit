require 'spec_helper'

describe API::User::Resources::ActivityTypes do
  include Warden::Test::Helpers

  let(:api_user) { FactoryGirl.create(:user) }
  let(:json) { JSON.parse(response.body) }

  shared_examples 'an activity_type' do
    its(['id']) { should be_present }
    its(['name']) { should be_present }
  end

  before do
    login_as api_user
  end

  describe 'GET /api/activity_types' do
    let!(:activity_type) { FactoryGirl.create(:activity_type) }

    before do
      get '/api/activity_types'
    end

    it 'returns a list of activity types' do
      json.should have(1).items
    end

    it_behaves_like 'an activity_type' do
      subject { json.first }
    end
  end

end
