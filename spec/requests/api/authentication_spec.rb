require 'spec_helper'

describe 'API::Authentication' do
  include RequestHelpers

  let(:user) { FactoryGirl.create(:user) }

  it 'requires authentication' do
    get '/api/ping'
    response.status.should eq(401)
  end

  describe 'token' do
    it 'authenticates' do
      get '/api/ping', {}, { 'HTTP_X_AUTH_TOKEN' => user.authentication_token }
      response.status.should eq(200)
    end
  end

  describe 'existing session', type: :feature do
    it 'authenticates' do
      visit '/api/ping'
      page.status_code.should eq(401)

      login user

      visit '/api/ping'
      page.status_code.should eq(200)
    end
  end
end
