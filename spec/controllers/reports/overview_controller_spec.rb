require 'spec_helper'

describe Reports::OverviewController do

  let(:user) { FactoryGirl.create(:user) }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :index, user_id: user
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do

    before do
      test_sign_in user
    end

    describe 'GET "index"' do
      it 'assigns the correct instance variables' do
        get :index, user_id: user
        assigns(:uberzeit).should_not be_nil
        assigns(:month_total_work).should_not be_nil
        assigns(:month_percent_done).should_not be_nil
        assigns(:personal_absences).should_not be_nil
        assigns(:team_absences).should_not be_nil
        assigns(:vacation_redeemed).should_not be_nil
        assigns(:vacation_remaining).should_not be_nil
      end

      it 'renders the :index template' do
        get :index, user_id: user
        response.should render_template :index
      end
    end

  end

end
