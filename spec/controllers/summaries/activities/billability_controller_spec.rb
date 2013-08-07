require 'spec_helper'


describe Summaries::Activities::BillabilityController do

  let(:user) { FactoryGirl.create(:user) }
  let(:team_leader) { FactoryGirl.create(:team_leader) }
  let(:admin) { FactoryGirl.create(:admin) }

  describe 'access' do
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

      describe 'GET "index"' do
        it 'denies access' do
          get :index
          response.status.should == 403
        end
      end
    end

    context 'for signed-in teamleaders' do
      before do
        test_sign_in team_leader
      end

      describe 'GET "index"' do
        it 'grant access' do
          get :index
          response.status.should == 200
        end
      end
    end

    context 'for signed-in admins' do
      before do
        test_sign_in admin
      end

      describe 'GET "index"' do
        it 'grant access' do
          get :index
          response.status.should == 200
        end
      end
    end
  end

end
