require 'spec_helper'

describe UsersController do
  render_views

  let(:user) { FactoryGirl.create(:user) }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :edit, id: user
      response.should redirect_to(new_session_path)
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
        get :edit, id: user
        response.should render_template :edit
      end
    end

    describe 'GET "show"' do
      it 'assigns the user to @user' do
        get :show, id: user.id
        assigns(:user).should eq(user)
      end

      it 'renders the :show template' do
        get :show, id: user
        response.should render_template :show
      end
    end

    describe 'PUT "update"' do
      context 'with valid attributes' do
        it 'changes the time zone' do
          put :update, id: user.id, user: { time_zone: 'Tokyo' }
          user.reload
          user.time_zone.should eq('Tokyo')
        end

        it 'should redirect to updated user' do
          put :update, id: user.id, user: { time_zone: 'Tokyo' }
          response.should redirect_to edit_user_path(user)
        end
      end

      context 'with invalid attributes' do
        it 're-renders the :edit template' do
          put :update, id: user.id, user: { time_zone: 'Utopia' }
          response.should render_template :edit
        end
      end
    end

  end
end
