require 'spec_helper'

describe SessionsController do
  render_views

  before do
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:password]
  end

  describe 'GET new' do
    context 'without the password provider' do
      context 'with an other provider' do
        before(:each) do
          UberZeit.config.auth_providers = [ { 'provider' => 'cas' } ]
        end

        it 'redirects to omniauth' do
          get :new
          response.should redirect_to('/auth/cas')
        end
      end
      context 'with multiple other providers' do
        before(:each) do
          UberZeit.config.auth_providers = [ { 'provider' => 'cas' }, { 'provider' => 'developer' } ]
        end

        it 'is a success' do
          get :new
          response.response_code.should eq(200)
        end
      end
    end

    context 'with the password provider' do
      before(:each) do
        UberZeit.config.auth_providers = [ { 'provider' => 'password' } ]
      end

      it 'is a success' do
        get :new
        response.response_code.should eq(200)
      end
    end
  end

  describe 'POST create' do
    it 'shows a message when the requested user could not be found' do
      env = {'omniauth.auth' => {'uid' => 'tobiasfuenke'}}
      request.stub(:env).and_return(env)
      post :create, provider: :cas
      response.response_code.should eq(403)
    end
  end
end
