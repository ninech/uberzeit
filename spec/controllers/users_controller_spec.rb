require 'spec_helper'

describe UsersController do
  render_views

  context 'for non-signed in users' do
    it 'denies access' do
      user = FactoryGirl.create(:user)
      get :edit, id: user
      response.should redirect_to(root_path)
      flash[:error].should_not be_nil
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in
    end

    describe 'GET "edit"' do
      before do
        @user = FactoryGirl.create(:user)
      end

      it 'assigns the to-be edited user to @user' do
        get :edit, id: @user
        assigns(:user).should eq(@user)
      end

      it 'renders the :edit template' do
        get :edit, id: @user
        response.should render_template :edit
      end
    end

    describe 'PUT "update"' do
      before do
        @user = FactoryGirl.create(:user, time_zone: 'Bern')
      end

      context 'with valid attributes' do
        it 'changes the time zone' do
          put :update, id: @user, user: FactoryGirl.attributes_for(:user, time_zone: 'Tokyo')
          @user.reload
          @user.time_zone.should eq('Tokyo')
        end

        it 'should redirect to updated user' do
          put :update, id: @user, user: FactoryGirl.attributes_for(:user, time_zone: 'Tokyo')
          response.should redirect_to edit_user_path(@user)
        end
      end

      context 'with invalid attributes' do
        it 're-renders the :edit template' do
          put :update, id: @user, user: FactoryGirl.attributes_for(:user, time_zone: 'Utopia')
          response.should render_template :edit
        end
      end
    end

  end
end
