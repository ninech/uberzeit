require 'spec_helper'

describe SingleEntriesController do
  render_views

  context 'for non-signed in users' do
    it 'denies access' do
      time_sheet = FactoryGirl.create(:time_sheet)
      expect { get :new, time_sheet_id: time_sheet.id }.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'for signed-in users' do

    let(:user) { FactoryGirl.create(:user) }
    let(:time_sheet) { user.sheets.first }

    before do
      test_sign_in user
    end

    describe 'GET "new"' do
      it 'assigns a single entry to @single_entry' do
        get :new, time_sheet_id: time_sheet.id
        assigns(:single_entry).class.should be(SingleEntry)
      end

      it 'renders the :new template' do
        get :new, time_sheet_id: time_sheet.id
        response.should render_template :new
      end
    end

    describe 'GET "edit"' do
      before do
        @single_entry = FactoryGirl.create(:single_entry, time_sheet: time_sheet)
      end

      it 'assigns the to-be entry to @single_entry' do
        get :edit, id: @single_entry, time_sheet_id: @single_entry.time_sheet
        assigns(:single_entry).should eq(@single_entry)
      end

      it 'renders the :edit template' do
        get :edit, id: @single_entry, time_sheet_id: @single_entry.time_sheet
        assigns(:single_entry).should eq(@single_entry)
      end
    end

    describe 'PUT "update"' do
      before do
        @single_entry = FactoryGirl.create(:single_entry, time_sheet: time_sheet)
      end

      context 'with valid attributes' do
        it 'changes @single_entry\'s attributes' do
          put :update, id: @single_entry, time_sheet_id: @single_entry.time_sheet, single_entry: FactoryGirl.attributes_for(:single_entry, whole_day: true)
          @single_entry.reload
          @single_entry.whole_day.should be_true
        end

        it 'redirects to the sheet overview' do
          put :update, id: @single_entry, time_sheet_id: @single_entry.time_sheet, single_entry: FactoryGirl.attributes_for(:single_entry)
          response.should redirect_to @single_entry.time_sheet
        end
      end

      context 'with invalid attributes' do
        it 're-renders the :edit template' do
          put :update, id: @single_entry, time_sheet_id: @single_entry.time_sheet, single_entry: FactoryGirl.attributes_for(:invalid_single_entry)
          response.should render_template :edit
        end
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        it 'creates a new single entry' do
          expect do
            time_type = FactoryGirl.create(:time_type_work)
            post :create, time_sheet_id: time_sheet.id, single_entry: FactoryGirl.attributes_for(:single_entry, time_type_id: time_type.id)
          end.to change(SingleEntry,:count).by(1)
        end

        it 'redirects to the sheet overview' do
          time_type = FactoryGirl.create(:time_type_work)
          post :create, time_sheet_id: time_sheet.id, single_entry: FactoryGirl.attributes_for(:single_entry, time_type_id: time_type.id)
          response.should redirect_to time_sheet
        end
      end

      context 'with invalid attributes' do
        it 'does not save the new single entry' do
          expect { post :create, time_sheet_id: time_sheet.id, single_entry: FactoryGirl.attributes_for(:invalid_single_entry) }.to_not change(SingleEntry,:count)
        end

        it 're-renders the :new template' do
          post :create, time_sheet_id: time_sheet.id, single_entry: FactoryGirl.attributes_for(:invalid_single_entry)
          response.should render_template :new
        end
      end
    end

    describe 'DELETE "destroy"' do
      before do
        @single_entry = FactoryGirl.create(:single_entry)
      end

      it 'deletes the entry' do
        expect { delete :destroy, id: @single_entry, time_sheet_id: @single_entry.time_sheet }.to change(SingleEntry,:count).by(-1)
      end

      it 'redirects to the time sheet' do
        delete :destroy, id: @single_entry, time_sheet_id: @single_entry.time_sheet
        response.should redirect_to @single_entry.time_sheet
      end
    end
  end
end
