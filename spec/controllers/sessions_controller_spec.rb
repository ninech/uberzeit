require 'spec_helper'

describe SessionsController do
  render_views

  before do
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
  end

  describe 'GET new' do
    it 'redirects to omniauth' do
      get :new
      response.should redirect_to('/auth/cas')
    end
  end

  describe 'POST create' do
    it 'shows a message when the requested user could not be found' do
      env = {'omniauth.auth' => {'uid' => 'tobiasfuenke'}}
      request.stub(:env).and_return(env)
      post :create, provider: :cas
      response.response_code.should eq(404)
    end
  end
end
