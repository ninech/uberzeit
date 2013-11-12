require 'spec_helper'


describe Reports::Activities::ComparisonController do

  let(:team) { FactoryGirl.create(:team) }

  let(:user) { FactoryGirl.create(:user, teams: [team]) }
  let(:team_leader) { FactoryGirl.create(:team_leader, teams: [team]) }
  let(:admin) { FactoryGirl.create(:admin) }

  def get_show(user_id = user.id)
    get :show, user_id: user_id
  end

  describe 'access' do
    context 'for non-signed in users' do
      it 'redirects to login' do
        get_show user.id
        response.should redirect_to(new_session_path)
      end
    end

    context 'for signed-in users' do
      before do
        test_sign_in user
      end

      describe 'GET "show"' do
        context 'with own user' do
          it 'grants access' do
            expect { get_show user.id }.to_not raise_error(CanCan::AccessDenied)
          end
        end

        context 'with other user' do
          it 'denies access' do
            expect { get_show team_leader.id }.to raise_error(CanCan::AccessDenied)
          end
        end
      end
    end

    context 'for signed-in teamleaders' do
      before do
        test_sign_in team_leader
      end

      describe 'GET "show"' do
        it 'grants access' do
          expect { get_show user.id }.to_not raise_error(CanCan::AccessDenied)
        end
      end
    end

    context 'for signed-in admins' do
      before do
        test_sign_in admin
      end

      describe 'GET "show"' do
        it 'grants access' do
          expect { get_show user.id }.to_not raise_error(CanCan::AccessDenied)
        end
      end
    end
  end

  describe 'GET "show"' do
    before do
      test_sign_in user
      get_show
    end

    it 'assigns the correct instance variables' do
      assigns(:range).should_not be_nil
      assigns(:data_points).should_not be_nil
    end

    it 'renders the :table template' do
      get_show
      response.should render_template :table
    end
  end
end
