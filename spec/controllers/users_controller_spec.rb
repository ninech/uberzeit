require 'spec_helper'

describe UsersController do
  render_views

  let!(:user) { FactoryGirl.create(:admin) }
  let(:team) { FactoryGirl.create(:team) }
  let(:valid_user_attributes) { { given_name: 'Dolan', name: 'Duck', email: 'doland@example.com', team_ids: [team.id] } }

  context 'for non-signed in users' do
    describe 'GET "edit"' do
      it 'redirects to login' do
        get :edit, id: user.id
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
          post :create, user: valid_user_attributes
          response.should redirect_to(new_session_path)
        end

        it 'does not change any attributes' do
          expect do
            post :create, user: valid_user_attributes
          end.not_to change(User, :count)
        end
      end
    end

    describe 'PUT "update"' do
      context 'with valid attributes' do
        it 'redirects to login' do
          put :update, id: user.id, name: 'Babo'
          response.should redirect_to(new_session_path)
        end

        it 'does not change any attributes' do
          put :update, id: user.id, name: 'Babo'
          user.name.should_not == 'Babo'
        end
      end
    end

    describe 'DELETE "destroy"' do
      it 'redirects to login' do
        delete :destroy, id: user.id
        response.should redirect_to(new_session_path)
      end

      it 'does not delete the user' do
        expect do
          delete :destroy, id: user.id
        end.to_not change(User, :count)
      end
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in user
    end

    describe 'GET "edit"' do
      it 'assigns the to-be edited user to @user' do
        get :edit, id: user.id
        assigns(:user).should eq(user)
      end

      it 'renders the :edit template' do
        get :edit, id: user.id
        response.should render_template :edit
      end
    end

    describe 'GET "new"' do
      it 'assigns the to-be edited user to @user' do
        get :new
        assigns(:user).id.should be_nil
      end

      it 'renders the :new template' do
        get :new
        response.should render_template :new
      end
    end

    describe 'PUT "update"' do
      context 'with valid attributes' do
        it 'changes user\'s attributes' do
          expect {
            put :update, id: user.id, user: valid_user_attributes
            user.reload
          }.to change(user, :name).to('Duck')
        end

        it "changes user's team association" do
          expect {
            put :update, id: user.id, user: valid_user_attributes
            user.reload
          }.to change(user, :teams).to([team])
        end

        it 'redirects to the overview' do
          put :update, id: user.id, user: valid_user_attributes
          response.should redirect_to users_path
        end
      end

      context 'with invalid attributes' do
        it 'does not change user\'s attributes' do
          expect {
            put :update, id: user.id, user: { email: 'doland@example' }
            user.reload
          }.not_to change(user, :email)
        end

        it 're-renders the :edit template' do
          put :update, id: user.id, user: { email: 'doland@example' }
          response.should render_template :edit
        end
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        it 'creates a user' do
          expect {
            post :create, user: valid_user_attributes
          }.to change(User, :count)
        end

        it 'redirects to the overview' do
          post :create, user: valid_user_attributes
          response.should redirect_to users_path
        end
      end

      context 'with invalid attributes' do
        it 'does not create a user' do
          expect {
            post :create, user: { email: 'doland@example' }
          }.not_to change(User, :count)
        end

        it 're-renders the :edit template' do
          post :create, user: { email: 'doland@example' }
          response.should render_template :new
        end
      end
    end

    describe 'DELETE "destroy"' do
      it 'does delete a user' do
        expect do
          delete :destroy, id: user.id
        end.to change(User, :count).by(-1)
      end

      it 'does delete the user' do
        delete :destroy, id: user.id
        User.where(id: user.id).count.should == 0
      end
    end

  end
end
