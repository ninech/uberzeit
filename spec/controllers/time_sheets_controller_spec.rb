require 'spec_helper'

describe TimeSheetsController do
  render_views

  context 'for non-signed in users' do
    it 'denies access' do
      get :index
      response.code.should eq('401')
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in
    end

    describe 'GET "index"' do
      it 'populates an array of sheets' do
        sheet = FactoryGirl.create(:time_sheet)
        get :index
        assigns(:time_sheets).should eq(TimeSheet.all)
      end

      it 'renders the :index template' do
        get :index
        response.should render_template :index
      end
    end

    describe 'GET "show"' do
      it 'assigns @sheet' do
        sheet = FactoryGirl.create(:time_sheet)
        get :show, id: sheet
        assigns(:time_sheet).should eq(sheet)
      end

      it 'renders the :show template' do
        sheet = FactoryGirl.create(:time_sheet)
        get :show, id: sheet
        response.should render_template :show
      end
    end
  end
end
