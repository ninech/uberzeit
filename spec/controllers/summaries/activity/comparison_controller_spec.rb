require 'spec_helper'


describe Summaries::Activity::ComparisonController do

  let(:team) { FactoryGirl.create(:team) }

  let(:user) { FactoryGirl.create(:user, teams: [team]) }
  let(:team_leader) { FactoryGirl.create(:team_leader, teams: [team]) }
  let(:admin) { FactoryGirl.create(:admin) }

  def get_index(user_id = nil, year = nil, month = nil)
    user_id ||= user.id
    year ||= Date.current.year
    month ||= Date.current.month
    get :index, user_id: user_id, year: year, month: month
  end

  describe 'access' do
    context 'for non-signed in users' do
      it 'redirects to login' do
        get_index user.id
        response.should redirect_to(new_session_path)
      end
    end

    context 'for signed-in users' do
      before do
        test_sign_in user
      end

      describe 'GET "index"' do
        context 'with own user' do
          it 'grants access' do
            expect { get_index user.id }.to_not raise_error(CanCan::AccessDenied)
          end
        end

        context 'with other user' do
          it 'denies access' do
            expect { get_index team_leader.id }.to raise_error(CanCan::AccessDenied)
          end
        end
      end
    end

    context 'for signed-in teamleaders' do
      before do
        test_sign_in team_leader
      end

      describe 'GET "index"' do
        it 'grants access' do
          expect { get_index user.id }.to_not raise_error(CanCan::AccessDenied)
        end
      end
    end

    context 'for signed-in admins' do
      before do
        test_sign_in admin
      end

      describe 'GET "index"' do
        it 'grants access' do
          expect { get_index user.id }.to_not raise_error(CanCan::AccessDenied)
        end
      end
    end
  end

  describe 'GET "index"' do
    before do
      test_sign_in user
      get_index
    end

    it 'assigns the correct instance variables' do
      assigns(:year).should_not be_nil
      assigns(:month).should_not be_nil
      assigns(:range).should_not be_nil
      assigns(:data_points).should_not be_nil
    end

    it 'renders the :index template' do
      get_index
      response.should render_template :index
    end
  end
end
