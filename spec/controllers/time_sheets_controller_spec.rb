require 'spec_helper'

describe TimeSheetsController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:sheet) { user.time_sheets.first }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :show, id: sheet, date: Date.today
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in user
    end

    describe 'GET "show"' do
    end

  end
end
