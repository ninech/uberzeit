require 'spec_helper'

describe RecurringEntriesController do
  render_views

  context 'for non-signed in users' do
    it 'denies access' do
      time_sheet = FactoryGirl.create(:time_sheet)
      get :new, time_sheet_id: time_sheet
      response.code.should eq('401')
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in
    end

    describe 'GET "new"' do
      it 'assigns a recurring entry to @recurring_entry' do
        time_sheet = FactoryGirl.create(:time_sheet)
        get :new, time_sheet_id: time_sheet
        assigns(:entry).class.should be(RecurringEntry)
      end

      it 'renders the :new template' do
        time_sheet = FactoryGirl.create(:time_sheet)
        get :new, time_sheet_id: time_sheet
        response.should render_template :new
      end
    end

    describe 'GET "edit"' do
      before do
        @entry = FactoryGirl.create(:recurring_entry)
      end

      it 'assigns the to-be entry to @entry' do
        get :edit, id: @entry, time_sheet_id: @entry.time_sheet
        assigns(:entry).should eq(@entry)
      end

      it 'renders the :edit template' do
        get :edit, id: @entry, time_sheet_id: @entry.time_sheet
        assigns(:entry).should eq(@entry)
      end
    end

    describe 'PUT "update"' do
      before do
        @entry = FactoryGirl.create(:recurring_entry)
      end

      context 'with valid attributes' do
        it 'changes @entry\'s attributes' do
          tt = FactoryGirl.create(:time_type)
          put :update, id: @entry, time_sheet_id: @entry.time_sheet, recurring_entry: FactoryGirl.attributes_for(:recurring_entry, time_type_id: tt.id)
          @entry.reload
          @entry.time_type.id.should eq(tt.id)
        end

        it 'redirects to the sheet overview' do
          put :update, id: @entry, time_sheet_id: @entry.time_sheet, recurring_entry: FactoryGirl.attributes_for(:recurring_entry)
          response.should redirect_to @entry.time_sheet
        end
      end

      context 'with invalid attributes' do
        it 're-renders the :edit template' do
          put :update, id: @entry, time_sheet_id: @entry.time_sheet, recurring_entry: FactoryGirl.attributes_for(:invalid_recurring_entry)
          response.should render_template :edit
        end
      end
    end

    describe 'POST "create"' do
      before do
        @time_sheet = FactoryGirl.create(:time_sheet)
      end

      context 'with valid attributes' do
        it 'creates a new recurring entry' do
          expect do
            time_type = FactoryGirl.create(:time_type_work)
            post :create, time_sheet_id: @time_sheet, recurring_entry: FactoryGirl.attributes_for(:recurring_entry, time_type_id: time_type.id)
          end.to change(RecurringEntry,:count).by(1)
        end

        it 'redirects to the sheet overview' do
          time_type = FactoryGirl.create(:time_type_work)
          post :create, time_sheet_id: @time_sheet, recurring_entry: FactoryGirl.attributes_for(:recurring_entry, time_type_id: time_type.id) 
          response.should redirect_to @time_sheet
        end
      end

      context 'with invalid attributes' do
        it 'does not save the new recurring entry' do
          expect { post :create, time_sheet_id: @time_sheet, recurring_entry: FactoryGirl.attributes_for(:invalid_recurring_entry) }.to_not change(RecurringEntry,:count)
        end

        it 're-renders the :new template' do
          post :create, time_sheet_id: @time_sheet, recurring_entry: FactoryGirl.attributes_for(:invalid_recurring_entry)
          response.should render_template :new
        end
      end
    end

    describe 'DELETE "destroy"' do
      before do
        @recurring_entry = FactoryGirl.create(:recurring_entry)
      end

      it 'deletes the entry' do
        expect { delete :destroy, id: @recurring_entry, time_sheet_id: @recurring_entry.time_sheet }.to change(RecurringEntry,:count).by(-1)
      end

      it 'redirects to the time sheet' do
        delete :destroy, id: @recurring_entry, time_sheet_id: @recurring_entry.time_sheet
        response.should redirect_to @recurring_entry.time_sheet
      end
    end
  end
end
