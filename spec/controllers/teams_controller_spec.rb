require 'spec_helper'

describe TeamsController do
  render_views

  let!(:admin) { FactoryGirl.create(:admin) }
  let(:valid_team_attributes) { { name: 'Pro Gamers' } }
  let!(:team) { FactoryGirl.create :team }

  context 'for non-signed in users' do
    describe 'GET "edit"' do
      it 'redirects to login' do
        get :edit, id: team.id
        response.should redirect_to(new_session_path)
      end
    end

    describe 'GET "new"' do
      it 'redirects to login' do
        get :new
        response.should redirect_to(new_session_path)
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        it 'redirects to login' do
          post :create, team: valid_team_attributes
          response.should redirect_to(new_session_path)
        end

        it 'does create a team' do
          expect do
            post :create, team: valid_team_attributes
          end.not_to change(Team, :count)
        end
      end
    end

    describe 'PUT "update"' do
      context 'with valid attributes' do
        it 'redirects to login' do
          put :update, id: team.id, name: 'Babo'
          response.should redirect_to(new_session_path)
        end

        it 'does not change any attributes' do
          put :update, id: team.id, name: 'Babo'
          team.name.should_not == 'Babo'
        end
      end
    end

    describe 'DELETE "destroy"' do
      it 'redirects to login' do
        delete :destroy, id: team.id
        response.should redirect_to(new_session_path)
      end

      it 'does not delete the team' do
        expect do
          delete :destroy, id: team.id
        end.to_not change(Team, :count)
      end
    end
  end

  context 'for signed-in admins' do
    before do
      test_sign_in admin
    end

    describe 'GET "edit"' do
      it 'assigns the to-be edited team to @team' do
        get :edit, id: team.id
        assigns(:team).should eq(team)
      end

      it 'renders the :edit template' do
        get :edit, id: team.id
        response.should render_template :edit
      end
    end

    describe 'GET "new"' do
      it 'assigns the to-be edited team to @team' do
        get :new
        assigns(:team).id.should be_nil
      end

      it 'renders the :new template' do
        get :new
        response.should render_template :new
      end
    end

    describe 'PUT "update"' do
      context 'with valid attributes' do
        it 'changes team\'s attributes' do
          expect {
            put :update, id: team.id, team: valid_team_attributes
            team.reload
          }.to change(team, :name).to('Pro Gamers')
        end

        it 'redirects to the overview' do
          put :update, id: team.id, team: valid_team_attributes
          response.should redirect_to teams_path
        end
      end

      context 'with invalid attributes' do
        it 'does not change team\'s attributes' do
          expect {
            put :update, id: team.id, team: { name: '' }
            team.reload
          }.not_to change(team, :name)
        end

        it 're-renders the :edit template' do
          put :update, id: team.id, team: { name: '' }
          response.should render_template :edit
        end
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        it 'creates a team' do
          expect {
            post :create, team: valid_team_attributes
          }.to change(Team, :count)
        end

        it 'redirects to the overview' do
          post :create, team: valid_team_attributes
          response.should redirect_to teams_path
        end
      end

      context 'with invalid attributes' do
        it 'does not create a team' do
          expect {
            post :create, team: { name: '' }
          }.not_to change(Team, :count)
        end

        it 're-renders the :edit template' do
          post :create, team: { name: '' }
          response.should render_template :new
        end
      end
    end

    describe 'DELETE "destroy"' do
      it 'does delete a team' do
        expect do
          delete :destroy, id: team.id
        end.to change(Team, :count).by(-1)
      end

      it 'does delete the team' do
        delete :destroy, id: team.id
        Team.where(id: team.id).count.should == 0
      end
    end

  end
end
