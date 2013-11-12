require 'spec_helper'

describe RolesController do
  context 'for non-signed in users' do
    let!(:user) { FactoryGirl.create(:user) }

    describe 'GET "index"' do
      it 'redirects to login' do
        get :index, user_id: user.id
        response.should redirect_to(new_session_path)
      end
    end

    describe 'GET "new"' do
      it 'redirects to login' do
        get :new, user_id: user.id
        response.should redirect_to(new_session_path)
      end
    end

    describe 'POST "create"' do
      it 'redirects to login' do
        post :create, user_id: user.id, role: :admin
        response.should redirect_to(new_session_path)
      end

      it 'does not add the role to the user' do
        post :create, user_id: user.id, role: :admin
        user.should_not have_role(:admin)
      end
    end
  end

  context 'for signed in users' do
    let!(:user) { FactoryGirl.create(:admin) }

    before do
      test_sign_in user
    end

    let(:roles) { user.roles }

    describe 'GET "index"' do
      it 'assigns the to-be edited roles to @roles' do
        get :index, user_id: user.id
        assigns(:roles).should eq(roles)
      end

      it 'renders the :index template' do
        get :index, user_id: user.id
        response.should render_template :index
      end
    end

    describe 'GET "new"' do
      it 'renders the :new template' do
        get :new, user_id: user.id
        response.should render_template :new
      end
    end

    describe 'POST "create"' do
      it 'assigns the role to the user' do
        post :create, user_id: user.id, user_role: { role: 'accountant' }
        user.should have_role(:accountant)
      end
    end
  end
end

