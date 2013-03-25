require 'spec_helper'

describe SummaryController do
  render_views


  context 'for non-signed in users' do
    it 'denies access' do
      sheet =  FactoryGirl.create(:time_sheet)
      expect { get :work_summary, id: sheet, year: 2013 }.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'for signed-in users' do

    let(:user) { FactoryGirl.create(:user) }
    let(:sheet) { user.time_sheets.first }
    let(:year) { 2013 }
    let(:month) { 3 }

    before do
      test_sign_in user
    end

    describe 'GET "work_summary"' do
      it 'assigns @time_sheet, @year, @rows and @total' do
        get :work_summary, id: sheet, year: year
        assigns(:time_sheet).should eq(sheet)
        assigns(:year).should_not be_nil
        assigns(:rows).should_not be_nil
        assigns(:total).should_not be_nil
      end

      it 'renders the :work_summary template' do
        get :work_summary, id: sheet, year: year
        response.should render_template :work_summary
      end
    end

    describe 'GET "work_summary_per_month"' do
      it 'assigns @time_sheet, @year, @month, @rows and @total' do
        get :work_summary_per_month, id: sheet, year: year, month: month, format: :javascript
        assigns(:time_sheet).should eq(sheet)
        assigns(:year).should_not be_nil
        assigns(:month).should_not be_nil
        assigns(:rows).should_not be_nil
        assigns(:total).should_not be_nil
      end
    end


    describe 'GET "absence_summary"' do
      it 'assigns @time_sheet, @year, @rows and @total' do
        get :absence_summary, id: sheet, year: year
        assigns(:time_sheet).should eq(sheet)
        assigns(:year).should_not be_nil
        assigns(:rows).should_not be_nil
        assigns(:total).should_not be_nil
      end

      it 'renders the :absence_summary template' do
        get :absence_summary, id: sheet, year: year
        response.should render_template :absence_summary
      end
    end

    describe 'GET "absence_summary_per_month"' do
      it 'assigns @time_sheet, @year, @month, @rows and @total' do
        get :absence_summary_per_month, id: sheet, year: year, month: month, format: :javascript
        assigns(:time_sheet).should eq(sheet)
        assigns(:year).should_not be_nil
        assigns(:month).should_not be_nil
        assigns(:rows).should_not be_nil
        assigns(:total).should_not be_nil
      end
    end

  end
end
