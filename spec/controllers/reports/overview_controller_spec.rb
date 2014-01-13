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

      context 'with no planned work' do
        before(:each) do
          TimeSheet.any_instance.stub(:planned_working_time).and_return(0)
        end

        it 'does not raise an error' do
          expect do
            get :index, user_id: user
          end.not_to raise_error
        end
      end

      context 'on 1st january' do
        before { Timecop.freeze('2014-01-01'.to_date) }

        it 'does not raise an error' do
          expect { get :index, user_id: user }.to_not raise_error
        end
      end
    end

  end

end
