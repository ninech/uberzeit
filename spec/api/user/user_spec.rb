require 'spec_helper'
require 'rack/test'

describe API::User do
  include Rack::Test::Methods
  include Warden::Test::Helpers

  let(:api_user) { FactoryGirl.create(:user) }
  let(:json) { JSON.parse(last_response.body) }

  before do
    login_as api_user
  end

  shared_examples 'a validation error' do
    its(['status']) { should eq(422) }
    its(['message']) { should be_present }
    its(['errors']) { should be_kind_of(Array) }
  end

  context 'ping?' do
    it 'pong!' do
      get '/api/ping'
      last_response.status.should eq(200)
      json.should include('pong')
    end
  end

end
