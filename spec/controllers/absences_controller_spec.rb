require 'spec_helper'

describe AbsencesController do

  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:time_sheet) { user.time_sheets.first }

  context 'for signed-in admins' do

    before do
      test_sign_in admin
    end

    describe 'GET "index"' do
      it 'assigns @time_types' do
        get :index, time_sheet_id: time_sheet.id
        assigns(:time_types).should eq(TimeType.absence)
      end

      it 'assigns @absences' do
        absence = FactoryGirl.create(:absence, start_date: '2013-01-01'.to_date, end_date: '2013-01-02', time_sheet: time_sheet)
        get :index, time_sheet_id: time_sheet.id
        assigns(:absences).length.should eq(2)
        assigns(:absences)['2013-01-01'].length.should eq(1)
        assigns(:absences)['2013-01-01'].first.should be_instance_of(TimeChunk)
        assigns(:absences)['2013-01-02'].length.should eq(1)
        assigns(:absences)['2013-01-02'].first.should be_instance_of(TimeChunk)
      end

      it 'handles a year parameter' do
        absence = FactoryGirl.create(:absence, start_date: '2013-01-01'.to_date, end_date: '2013-01-02', time_sheet: time_sheet)
        get :index, time_sheet_id: time_sheet.id, year: 2012
        assigns(:absences).length.should eq(0)
      end
    end

    describe 'GET "new"' do

      it 'assigns @time_types' do
        get :new, time_sheet_id: time_sheet.id
        assigns(:time_types).should eq(TimeType.absence)
      end

      it 'ensures the absence has an empty recurring schedule' do
        get :new, time_sheet_id: time_sheet.id
        assigns(:absence).recurring_schedule.should_not be_persisted
      end

      context 'html' do
        it 'renders the new template without a layout' do
          controller.should_receive(:respond_with).with(instance_of(Absence), layout: true)
          get :new, time_sheet_id: time_sheet.id
        end
      end

      context 'xhr' do
        it 'renders the new template without a layout' do
          controller.should_receive(:respond_with).with(instance_of(Absence), layout: false)
          xhr :get, :new, time_sheet_id: time_sheet.id
        end
      end

    end

    describe 'POST "create"' do
      it 'creates a new absence' do
        expect { post :create, time_sheet_id: time_sheet.id, absence: FactoryGirl.attributes_for(:absence, time_type_id: TEST_TIME_TYPES[:vacation].id) }.to change(Absence, :count)
      end

      it 'redirects to the absence view of the year of the new created absence' do
        post :create, time_sheet_id: time_sheet.id, absence: FactoryGirl.attributes_for(:absence, time_type_id: TEST_TIME_TYPES[:vacation].id)
        response.should redirect_to("/time_sheets/#{time_sheet.id}/absences/year/#{Absence.last.start_date.year}")
      end
    end

    describe 'GET "edit"' do
      let(:absence) { FactoryGirl.create(:absence, time_sheet: time_sheet) }

      it 'assigns @time_types' do
        get :edit, time_sheet_id: time_sheet.id, id: absence.id
        assigns(:time_types).should eq(TimeType.absence)
      end

      it 'ensures the absence has a recurring schedule' do
        absence.recurring_schedule.destroy
        get :edit, time_sheet_id: time_sheet.id, id: absence.id
        assigns(:absence).recurring_schedule.should_not be_persisted
      end

      context 'html' do
        it 'renders the new template without a layout' do
          controller.should_receive(:respond_with).with(instance_of(Absence), layout: true)
          get :edit, time_sheet_id: time_sheet.id, id: absence.id
        end
      end

      context 'xhr' do
        it 'renders the new template without a layout' do
          controller.should_receive(:respond_with).with(instance_of(Absence), layout: false)
          xhr :get, :edit, time_sheet_id: time_sheet.id, id: absence.id
        end
      end

    end

    describe 'PUT "update"' do
      let(:absence) { FactoryGirl.create(:absence, time_sheet: time_sheet) }
      it 'updates the absence' do
        expect {
          put :update, time_sheet_id: time_sheet.id, id: absence.id, absence: {start_date: '2012-01-01'.to_date}
        }.to change { absence.reload.start_date }
      end

      it 'redirects to the absence view of the year of the updated absence' do
        put :update, time_sheet_id: time_sheet.id, id: absence.id, absence: {start_date: '2012-01-01'.to_date}
        response.should redirect_to("/time_sheets/#{time_sheet.id}/absences/year/#{Absence.last.start_date.year}")
      end
    end

    describe 'DELETE "destroy"' do
      let(:absence) { FactoryGirl.create(:absence, time_sheet: time_sheet) }

      it 'removes absence' do
        absence
        expect { delete :destroy, time_sheet_id: time_sheet.id, id: absence.id }.to change(Absence, :count)
      end

      it 'redirects to the absence view of the year of the removed absence' do
        delete :destroy, time_sheet_id: time_sheet.id, id: absence.id
        response.should redirect_to("/time_sheets/#{time_sheet.id}/absences/year/#{absence.start_date.year}")
      end
    end

  end
end
