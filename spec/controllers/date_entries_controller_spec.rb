require 'spec_helper'

describe DateEntriesController do
  render_views

  context 'for non-signed in users' do
    it 'denies access' do
      time_sheet = FactoryGirl.create(:time_sheet)
      expect { get :new, time_sheet_id: time_sheet.id }.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'for signed-in users' do
    let(:user) { FactoryGirl.create(:user) }
    let(:time_sheet) { user.time_sheets.first }
    let(:date_entry) { FactoryGirl.create(:date_entry, time_sheet: time_sheet) }

    before do
      test_sign_in user
    end

    describe 'GET "new"' do
      it 'assigns a single entry to date_entry' do
        get :new, time_sheet_id: time_sheet.id
        assigns(:date_entry).class.should be(DateEntry)
      end

      it 'renders the :new template' do
        get :new, time_sheet_id: time_sheet.id
        response.should render_template :new
      end
    end

    describe 'GET "edit"' do
      before do
        date_entry = FactoryGirl.create(:date_entry, time_sheet: time_sheet)
      end

      it 'assigns the to-be entry to date_entry' do
        get :edit, id: date_entry, time_sheet_id: date_entry.time_sheet
        assigns(:date_entry).should eq(date_entry)
      end

      it 'renders the :edit template' do
        get :edit, id: date_entry, time_sheet_id: date_entry.time_sheet
        assigns(:date_entry).should eq(date_entry)
      end
    end

    describe 'PUT "update"' do
      before do
        date_entry = FactoryGirl.create(:date_entry, time_sheet: time_sheet)
      end

      context 'with valid attributes' do
        it 'changes date_entry\'s attributes' do
          date_now = Date.today
          put :update, id: date_entry, time_sheet_id: date_entry.time_sheet, date_entry: FactoryGirl.attributes_for(:date_entry, start_date: date_now, end_date: date_now)
          date_entry.reload
          date_entry.start_date.should eq(date_now)
          date_entry.end_date.should eq(date_now)
        end

        it 'redirects to the sheet overview' do
          put :update, id: date_entry, time_sheet_id: date_entry.time_sheet, date_entry: FactoryGirl.attributes_for(:date_entry)
          response.should redirect_to date_entry.time_sheet
        end
      end

      context 'with invalid attributes' do
        it 're-renders the :edit template' do
          put :update, id: date_entry, time_sheet_id: date_entry.time_sheet, date_entry: FactoryGirl.attributes_for(:invalid_date_entry)
          response.should render_template :edit
        end
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        it 'creates a new single entry' do
          expect do
            time_type = FactoryGirl.create(:time_type_work)
            post :create, time_sheet_id: time_sheet.id, date_entry: FactoryGirl.attributes_for(:date_entry, time_type_id: time_type.id)
          end.to change(DateEntry,:count).by(1)
        end

        it 'redirects to the sheet overview' do
          time_type = FactoryGirl.create(:time_type_work)
          post :create, time_sheet_id: time_sheet.id, date_entry: FactoryGirl.attributes_for(:date_entry, time_type_id: time_type.id)
          response.should redirect_to time_sheet
        end
      end

      context 'with invalid attributes' do
        it 'does not save the new single entry' do
          expect { post :create, time_sheet_id: time_sheet.id, date_entry: FactoryGirl.attributes_for(:invalid_date_entry) }.to_not change(DateEntry,:count)
        end

        it 're-renders the :new template' do
          post :create, time_sheet_id: time_sheet.id, date_entry: FactoryGirl.attributes_for(:invalid_date_entry)
          response.should render_template :new
        end
      end
    end

    describe 'DELETE "destroy"' do

      it 'deletes the entry' do
        date_entry
        expect { delete :destroy, id: date_entry, time_sheet_id: date_entry.time_sheet }.to change(DateEntry,:count).by(-1)
      end

      it 'redirects to the time sheet' do
        delete :destroy, id: date_entry, time_sheet_id: date_entry.time_sheet
        response.should redirect_to date_entry.time_sheet
      end
    end
  end
end
