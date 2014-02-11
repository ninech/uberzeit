require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      render nothing: true
    end
  end

  let(:user) { FactoryGirl.create(:user) }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :index
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in user
    end

    it 'won\'t redirect to login' do
      get :index
      response.status.should eq(200)
    end

    context 'for deactivated users' do
      let(:user) { FactoryGirl.create(:user, active: false) }

      it 'denies access' do
        get :index
        response.status.should eq(401)
      end
    end
  end

end

