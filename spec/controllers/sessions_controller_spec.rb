require 'spec_helper'

describe SessionsController do

  before do
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
  end

  describe 'POST create' do
    it 'creates the user when signing in' do
      expect { get :create, provider: :cas }.to change(User, :count)
    end
  end

  describe 'GET new' do
    it 'redirects to omniauth' do
      get :new
      response.should redirect_to('/auth/cas')
    end
  end

end
