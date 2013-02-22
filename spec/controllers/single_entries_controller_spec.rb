require 'spec_helper'

describe SingleEntriesController do
  render_views

  context 'for non-signed in users' do
    let(:time_sheet) { FactoryGirl.create(:time_sheet) }
    it 'denies access' do
      get :new, time_sheet_id: time_sheet.id
      response.code.should eq('401')
    end
  end

  context 'for signed-in users' do
    before do
      @user = test_sign_in
    end

    describe 'GET "new"' do
      context 'with an existing time sheet' do
        let(:time_sheet) { FactoryGirl.create(:time_sheet) }
        before do
          get :new, time_sheet_id: time_sheet.id
        end

        it 'is successful' do
          response.should be_success
        end
      end
    end

    describe 'GET "edit"' do
      context 'with an existing single time entry' do
        let(:single_entry) { FactoryGirl.create(:single_entry) }
        before do
          get :edit, id: single_entry.id, time_sheet_id: single_entry.time_sheet.id 
        end

        it 'should be successful' do
          response.should be_success
        end
      end
    end

    describe 'PUT "update"' do
      context 'with an existing single time entry' do
        context 'with valid parameters' do
          let(:single_entry) { FactoryGirl.create(:single_entry) }
          before do
            put :update, time_sheet_id: single_entry.time_sheet.id, id: single_entry.id
          end

          it 'should redirect to the time sheet' do
            response.should redirect_to(time_sheet_path(single_entry.time_sheet))
          end
        end
      end
    end

    describe 'POST "create"' do
      context 'with valid parameters' do
        let(:time_type) { FactoryGirl.create(:time_type) }
        let(:time_sheet) { FactoryGirl.create(:time_sheet) }
        let(:params) { {start_time: '2013-01-01 08:00:00', end_time: '2013-01-01 10:00:00', time_type_id: time_type.id } }

        before do
          post :create, time_sheet_id: time_sheet.id, single_entry: params
          @single_entry = SingleEntry.last
        end

        it 'should redirect to the time sheet' do
          response.should redirect_to(time_sheet_path(@single_entry.time_sheet))
        end
      end
    end

    describe 'DELETE "destroy"' do
      let(:single_entry) { FactoryGirl.create(:single_entry) }

      it 'should redirect to the timesheet' do
        delete :destroy, id: single_entry[:id], time_sheet_id: single_entry.time_sheet.id
        response.should redirect_to(time_sheet_path(single_entry.time_sheet))
      end

      it 'should have deleted the entry' do
        delete :destroy, id: single_entry[:id], time_sheet_id: single_entry.time_sheet.id
        SingleEntry.all.include?(single_entry).should be_false
      end
    end
  end
end
