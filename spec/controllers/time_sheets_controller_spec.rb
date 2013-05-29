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
      it 'assigns @time_sheet' do
        get :show, id: sheet, date: Date.today
        assigns(:time_sheet).should eq(sheet)
      end

      it 'renders the :show template' do
        get :show, id: sheet, date: Date.today
        response.should render_template :show
      end
    end

    describe 'GET "summary_for_date"' do
      it 'assigns the correct instance variables' do
        get :summary_for_date, id: sheet, date: Date.today, format: :javascript
        assigns(:total).should_not be_nil
        assigns(:timer).should_not be_nil
        assigns(:bonus).should_not be_nil
        assigns(:week_total).should_not be_nil
      end
    end
  end
end
