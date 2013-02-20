require 'spec_helper'

describe TimeSheetsController do
  render_views

  describe 'GET "index"' do
    context 'for non-signed in users' do
      it 'denies access' do
        get :index, :user_id => 1
        response.code.should eq('401')
      end
    end

    context 'for signed in users' do
      before do
        user = test_sign_in
        get :index, :user_id => user.id
      end

      it 'can access' do
        response.should be_success
      end
    end
  end
end
