require 'spec_helper'

describe RecurringEntriesController do
  render_views

  # context 'for non-signed in users' do
  #   it 'denies access' do
  #     time_sheet = FactoryGirl.create(:time_sheet)
  #     expect { get :new, time_sheet_id: time_sheet.id }.to raise_error(CanCan::AccessDenied)
  #   end
  # end

  # context 'for signed-in users' do
  #   let(:user) { FactoryGirl.create(:user) }
  #   let(:time_sheet) { user.time_sheets.first }
  #   let(:recurring_entry) { FactoryGirl.create(:recurring_entry, time_sheet: time_sheet) }

  #   before do
  #     test_sign_in user
  #   end

  #   describe 'GET "new"' do
  #     it 'assigns a recurring entry to @recurring_entry' do
  #       get :new, time_sheet_id: time_sheet
  #       assigns(:recurring_entry).class.should be(RecurringEntry)
  #     end

  #     it 'renders the :new template' do
  #       get :new, time_sheet_id: time_sheet
  #       response.should render_template :new
  #     end
  #   end

  #   describe 'GET "edit"' do
  #     it 'assigns the to-be entry to recurring_entry' do
  #       get :edit, id: recurring_entry, time_sheet_id: recurring_entry.time_sheet
  #       assigns(:recurring_entry).should eq(recurring_entry)
  #     end

  #     it 'renders the :edit template' do
  #       get :edit, id: recurring_entry, time_sheet_id: recurring_entry.time_sheet
  #       assigns(:recurring_entry).should eq(recurring_entry)
  #     end
  #   end

  #   describe 'PUT "update"' do
  #     before do
  #       recurring_entry = FactoryGirl.create(:recurring_entry)
  #     end

  #     context 'with valid attributes' do
  #       it 'changes recurring_entry\'s attributes' do
  #         tt = FactoryGirl.create(:time_type)
  #         put :update, id: recurring_entry, time_sheet_id: recurring_entry.time_sheet, recurring_entry: FactoryGirl.attributes_for(:recurring_entry, time_type_id: tt.id)
  #         recurring_entry.reload
  #         recurring_entry.time_type.id.should eq(tt.id)
  #       end

  #       it 'redirects to the sheet overview' do
  #         put :update, id: recurring_entry, time_sheet_id: recurring_entry.time_sheet, recurring_entry: FactoryGirl.attributes_for(:recurring_entry)
  #         response.should redirect_to recurring_entry.time_sheet
  #       end
  #     end

  #     context 'with invalid attributes' do
  #       it 're-renders the :edit template' do
  #         put :update, id: recurring_entry, time_sheet_id: recurring_entry.time_sheet, recurring_entry: FactoryGirl.attributes_for(:invalid_recurring_entry)
  #         response.should render_template :edit
  #       end
  #     end
  #   end

  #   describe 'POST "create"' do
  #     context 'with valid attributes' do
  #       it 'creates a new recurring entry' do
  #         expect do
  #           time_type = FactoryGirl.create(:time_type_work)
  #           post :create, time_sheet_id: time_sheet, recurring_entry: FactoryGirl.attributes_for(:recurring_entry, time_type_id: time_type.id)
  #         end.to change(RecurringEntry,:count).by(1)
  #       end

  #       it 'redirects to the sheet overview' do
  #         time_type = FactoryGirl.create(:time_type_work)
  #         post :create, time_sheet_id: time_sheet, recurring_entry: FactoryGirl.attributes_for(:recurring_entry, time_type_id: time_type.id)
  #         response.should redirect_to time_sheet
  #       end
  #     end

  #     context 'with invalid attributes' do
  #       it 'does not save the new recurring entry' do
  #         expect { post :create, time_sheet_id: time_sheet, recurring_entry: FactoryGirl.attributes_for(:invalid_recurring_entry) }.to_not change(RecurringEntry,:count)
  #       end

  #       it 're-renders the :new template' do
  #         post :create, time_sheet_id: time_sheet, recurring_entry: FactoryGirl.attributes_for(:invalid_recurring_entry)
  #         response.should render_template :new
  #       end
  #     end
  #   end

  #   describe 'DELETE "destroy"' do
  #     it 'deletes the entry' do
  #       recurring_entry
  #       expect { delete :destroy, id: recurring_entry, time_sheet_id: recurring_entry.time_sheet }.to change(RecurringEntry,:count).by(-1)
  #     end

  #     it 'redirects to the time sheet' do
  #       delete :destroy, id: recurring_entry, time_sheet_id: recurring_entry.time_sheet
  #       response.should redirect_to recurring_entry.time_sheet
  #     end
  #   end
  # end
end
