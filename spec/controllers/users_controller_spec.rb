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

  end
end
