require 'spec_helper'

describe PasswordsController do

  let(:user) { FactoryGirl.create :user }

  context 'for non-signed in users' do
    describe 'GET "edit"' do
      it 'redirects to login' do
        get :edit, user_id: user.id
        response.should redirect_to(new_session_path)
      end
    end

    describe 'PUT "update"' do
      it 'redirects to login' do
        put :update, user_id: user.id
        response.should redirect_to(new_session_path)
      end
    end
  end

  context 'for signed in users' do
    before do
      test_sign_in user
    end

    describe 'GET "edit"' do
      before(:each) do
        get :edit, user_id: user.id
      end

      it 'is successful' do
        response.should be_success
      end
    end

    describe 'PUT "update"' do
      let(:password) { '5HgPPUZ9IR' }

      it 'changes the password' do
        expect do
          put :update, user_id: user.id, password: { password: password, password_confirmation: password }
          user.reload
        end.to change(user, :password_digest)
      end
    end
  end
end
