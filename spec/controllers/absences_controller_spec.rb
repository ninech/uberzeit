require 'spec_helper'

describe AbsencesController do

  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }

  context 'for signed-in admins' do

    before do
      test_sign_in admin
    end

    describe 'GET "index"' do
      it 'assigns @time_types' do
        get :index, user_id: user.id
        assigns(:time_types).should eq(TimeType.absence)
      end

      describe '@absences' do
        let!(:absence_of_another_user) { FactoryGirl.create(:absence, start_date: '2013-04-01', end_date: '2013-04-01') }
        let!(:absence) { FactoryGirl.create(:absence, start_date: '2013-01-01', end_date: '2013-01-02', user: user) }

        it 'assigns the absences of the current user' do
          get :index, user_id: user.id
          assigns(:absences).keys.length.should eq(2)
          assigns(:absences)['2013-01-01'.to_date].length.should eq(1)
          assigns(:absences)['2013-01-01'.to_date].first.should be_instance_of(Absence)
          assigns(:absences)['2013-01-02'.to_date].length.should eq(1)
          assigns(:absences)['2013-01-02'.to_date].first.should be_instance_of(Absence)
        end
      end

      it 'handles a year parameter' do
        absence = FactoryGirl.create(:absence, start_date: '2013-01-01'.to_date, end_date: '2013-01-02', user: user)
        get :index, user_id: user.id, year: 2012
        assigns(:absences).length.should eq(0)
      end

      it 'assigns @public_holidays' do
        rafs_birthday = FactoryGirl.create(:public_holiday, date: '2013-04-22', name: 'Its my birthday, men!')
        get :index, user_id: user.id
        assigns(:public_holidays).should eq({'2013-04-22'.to_date => rafs_birthday})
      end
    end

    describe 'GET "new"' do

      it 'assigns @time_types' do
        get :new, user_id: user.id
        assigns(:time_types).should eq(TimeType.absence)
      end

      it 'ensures the absence has an empty recurring schedule' do
        get :new, user_id: user.id
        assigns(:absence).schedule.should_not be_persisted
      end

      context 'html' do
        it 'renders the new template' do
          controller.should_receive(:respond_with).with(instance_of(Absence))
          get :new, user_id: user.id
        end
      end

      context 'xhr' do
        it 'renders the new template' do
          controller.should_receive(:respond_with).with(instance_of(Absence))
          xhr :get, :new, user_id: user.id
        end
      end

    end

    describe 'POST "create"' do
      it 'creates a new absence' do
        expect { post :create, user_id: user.id, absence: FactoryGirl.attributes_for(:absence, time_type_id: TEST_TIME_TYPES[:vacation].id) }.to change(Absence, :count)
      end

      it 'redirects to the absence view of the year of the new created absence' do
        post :create, user_id: user.id, absence: FactoryGirl.attributes_for(:absence, time_type_id: TEST_TIME_TYPES[:vacation].id)
        response.should redirect_to("/users/#{user.id}/absences/year/#{Absence.last.start_date.year}")
      end
    end

    describe 'GET "edit"' do
      let(:absence) { FactoryGirl.create(:absence, user: user) }

      it 'assigns @time_types' do
        get :edit, user_id: user.id, id: absence.id
        assigns(:time_types).should eq(TimeType.absence)
      end

      it 'ensures the absence has a recurring schedule' do
        absence.schedule.destroy
        get :edit, user_id: user.id, id: absence.id
        assigns(:absence).schedule.should_not be_persisted
      end

      context 'html' do
        it 'renders the new template' do
          controller.should_receive(:respond_with).with(instance_of(Absence))
          get :edit, user_id: user.id, id: absence.id
        end
      end

      context 'xhr' do
        it 'renders the new template' do
          controller.should_receive(:respond_with).with(instance_of(Absence))
          xhr :get, :edit, user_id: user.id, id: absence.id
        end
      end

    end

    describe 'PUT "update"' do
      let(:absence) { FactoryGirl.create(:absence, user: user) }
      it 'updates the absence' do
        expect {
          put :update, user_id: user.id, id: absence.id, absence: {start_date: '2012-01-01'.to_date}
        }.to change { absence.reload.start_date }
      end

      it 'redirects to the absence view of the year of the updated absence' do
        put :update, user_id: user.id, id: absence.id, absence: {start_date: '2012-01-01'.to_date}
        response.should redirect_to("/users/#{user.id}/absences/year/#{Absence.last.start_date.year}")
      end
    end

    describe 'DELETE "destroy"' do
      let(:absence) { FactoryGirl.create(:absence, user: user) }

      it 'removes absence' do
        absence
        expect { delete :destroy, user_id: user.id, id: absence.id }.to change(Absence, :count)
      end

      it 'redirects to the absence view of the year of the removed absence' do
        delete :destroy, user_id: user.id, id: absence.id
        response.should redirect_to("/users/#{user.id}/absences/year/#{absence.start_date.year}")
      end
    end

  end
end
