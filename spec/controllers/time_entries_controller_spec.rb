require 'spec_helper'

describe TimeEntriesController do
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
    let(:time_entry) { FactoryGirl.create(:time_entry, time_sheet: time_sheet) }

    before do
      test_sign_in user
    end

    describe 'GET "new"' do
      it 'assigns a single entry to time_entry' do
        get :new, time_sheet_id: time_sheet.id
        assigns(:time_entry).class.should be(TimeEntry)
      end

      it 'renders the :new template' do
        get :new, time_sheet_id: time_sheet.id
        response.should render_template :new
      end
    end

    describe 'GET "edit"' do
      before do
        time_entry = FactoryGirl.create(:time_entry, time_sheet: time_sheet)
      end

      it 'assigns the to-be entry to time_entry' do
        get :edit, id: time_entry, time_sheet_id: time_entry.time_sheet
        assigns(:time_entry).should eq(time_entry)
      end

      it 'renders the :edit template' do
        get :edit, id: time_entry, time_sheet_id: time_entry.time_sheet
        assigns(:time_entry).should eq(time_entry)
      end
    end

    describe 'PUT "update"' do
      before do
        time_entry = FactoryGirl.create(:time_entry, time_sheet: time_sheet)
      end

      context 'with valid attributes' do
        it 'changes time_entry\'s attributes' do
          time_now = Time.zone.now.round
          put :update, id: time_entry, time_sheet_id: time_entry.time_sheet, time_entry: FactoryGirl.attributes_for(:time_entry, start_time: time_now, end_time: time_now + 1.hour)
          time_entry.reload
          time_entry.start_time.to_i.should eq(time_now.to_i)
          time_entry.end_time.to_i.should eq(time_now.to_i + 1.hour)
        end

        it 'redirects to the sheet overview' do
          put :update, id: time_entry, time_sheet_id: time_entry.time_sheet, time_entry: FactoryGirl.attributes_for(:time_entry)
          response.should redirect_to time_entry.time_sheet
        end
      end

      context 'with invalid attributes' do
        it 're-renders the :edit template' do
          put :update, id: time_entry, time_sheet_id: time_entry.time_sheet, time_entry: FactoryGirl.attributes_for(:invalid_time_entry)
          response.should render_template :edit
        end
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        it 'creates a new single entry' do
          expect do
            time_type = FactoryGirl.create(:time_type_work)
            post :create, time_sheet_id: time_sheet.id, time_entry: FactoryGirl.attributes_for(:time_entry, time_type_id: time_type.id)
          end.to change(TimeEntry,:count).by(1)
        end

        it 'redirects to the sheet overview' do
          time_type = FactoryGirl.create(:time_type_work)
          post :create, time_sheet_id: time_sheet.id, time_entry: FactoryGirl.attributes_for(:time_entry, time_type_id: time_type.id)
          response.should redirect_to time_sheet
        end
      end

      context 'with invalid attributes' do
        it 'does not save the new single entry' do
          expect { post :create, time_sheet_id: time_sheet.id, time_entry: FactoryGirl.attributes_for(:invalid_time_entry) }.to_not change(TimeEntry,:count)
        end

        it 're-renders the :new template' do
          post :create, time_sheet_id: time_sheet.id, time_entry: FactoryGirl.attributes_for(:invalid_time_entry)
          response.should render_template :new
        end
      end
    end

    describe 'DELETE "destroy"' do

      it 'deletes the entry' do
        time_entry
        expect { delete :destroy, id: time_entry, time_sheet_id: time_entry.time_sheet }.to change(TimeEntry,:count).by(-1)
      end

      it 'redirects to the time sheet' do
        delete :destroy, id: time_entry, time_sheet_id: time_entry.time_sheet
        response.should redirect_to time_entry.time_sheet
      end
    end
  end
end
