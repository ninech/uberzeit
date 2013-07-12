require 'spec_helper'

describe ActivitiesController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:sheet) { user.time_sheets.first }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :index, user_id: user.id
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in user
    end

    describe 'GET "index"' do
      it 'assigns @lala' do
        get :index, user_id: user.id
      end

      it 'renders the :show template' do
        get :index, user_id: user.id
        response.should render_template :index
      end
    end
  end

end
