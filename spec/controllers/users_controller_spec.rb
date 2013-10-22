require 'spec_helper'

describe UsersController do
  render_views

  let!(:user) { FactoryGirl.create(:admin) }

  context 'for non-signed in users' do
    describe 'GET "edit"' do
      it 'redirects to login' do
        get :edit, id: user
        response.should redirect_to(new_session_path)
      end
    end

    describe 'GET "new"' do
      it 'redirects to login' do
        get :new
        response.should redirect_to(new_session_path)
      end
    end

    describe 'PUT "update"' do
      context 'with valid attributes' do
        it 'redirects to login' do
          put :update, id: user, name: 'Babo'
          response.should redirect_to(new_session_path)
        end

        it 'does not change any attributes' do
          put :update, id: user, name: 'Babo'
          user.name.should_not == 'Babo'
        end
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
            put :update, id: user.id, user: { given_name: 'Dolan', name: 'Duck', email: 'doland@example.com' }
            user.reload
          }.to change(user, :name).to('Duck')
        end

        it 'redirects to the overview' do
          put :update, id: user.id
          response.should redirect_to users_path
        end
      end

      context 'with invalid attributes' do
        render_views

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

  end
end
