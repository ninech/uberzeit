require 'spec_helper'

describe TimeSheetsController do
  render_views

  context 'for non-signed in users' do
    it 'denies access' do
      expect { get :index }.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'for signed-in users' do

    let(:user) { FactoryGirl.create(:user) }
    let(:sheet) { user.time_sheets.first }

    before do
      test_sign_in user
    end

    describe 'GET "index"' do
      it 'populates an array of sheets of the current user' do
        FactoryGirl.create(:time_sheet)
        get :index
        assigns(:time_sheets).should eq([sheet])
      end

      it 'renders the :index template' do
        get :index
        response.should render_template :index
      end
    end

    describe 'GET "show"' do
      it 'assigns @time_sheet' do
        get :show, id: sheet
        assigns(:time_sheet).should eq(sheet)
      end

      it 'renders the :show template' do
        get :show, id: sheet
        response.should render_template :show
      end
    end
  end
end
