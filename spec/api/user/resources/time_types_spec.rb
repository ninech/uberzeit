require 'spec_helper'

describe API::User::Resources::TimeTypes do
  include Warden::Test::Helpers

  let(:api_user) { FactoryGirl.create(:user) }
  let(:json) { JSON.parse(response.body) }

  shared_examples 'a time type' do
    its(['id']) { should be_present }
    its(['name']) { should be_present }
    its(['is_work']) { should_not be_nil  }
  end

  before do
    login_as api_user
  end

  describe 'GET /api/time_types' do
    before do
      get '/api/time_types'
    end

    it 'returns a list of time types' do
      json.should have(TEST_TIME_TYPES.length).items
    end

    it_behaves_like 'a time type' do
      subject { json.first }
    end
  end

end
