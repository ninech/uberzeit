require 'spec_helper'


describe Reports::Activities::FilterController do

  let(:team) { FactoryGirl.create(:team) }

  let(:user) { FactoryGirl.create(:user, teams: [team]) }
  let(:team_leader) { FactoryGirl.create(:team_leader, teams: [team]) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:accountant) { FactoryGirl.create(:accountant) }

  describe 'access' do
    context 'for non-signed in users' do
      it 'redirects to login' do
        get :index, start_date: '2010-01-01', end_date: '2010-01-31', group_by: 'activity_type'
        response.should redirect_to(new_session_path)
      end
    end

    context 'for signed-in users' do
      before do
        test_sign_in user
      end

      describe 'GET "index"' do
        it 'allows access' do
          expect { get :index, start_date: '2010-01-01', end_date: '2010-01-31', group_by: 'activity_type' }.to_not raise_error
        end
      end
    end

    context 'for signed-in teamleaders' do
      before do
        test_sign_in team_leader
      end

      describe 'GET "index"' do
        it 'grants access' do
          expect { get :index, start_date: '2010-01-01', end_date: '2010-01-31', group_by: 'activity_type' }.to_not raise_error
        end
      end
    end

    context 'for signed-in accountants' do
      before do
        test_sign_in accountant
      end

      describe 'GET "index"' do
        it 'grants access' do
          expect { get :index, start_date: '2010-01-01', end_date: '2010-01-31', group_by: 'activity_type' }.to_not raise_error
        end
      end
    end

    context 'for signed-in admins' do
      before do
        test_sign_in admin
      end

      describe 'GET "index"' do
        it 'grants access' do
          expect { get :index, start_date: '2010-01-01', end_date: '2010-01-31', group_by: 'activity_type' }.to_not raise_error
        end
      end
    end
  end

  describe 'activities' do
    let(:swag_ag) { FactoryGirl.create(:customer, name: 'swag ag') }
    let(:yolo_inc) { FactoryGirl.create(:customer, name: 'yolo inc') }

    let(:support) { FactoryGirl.create(:activity_type, name: 'support') }
    let(:maintenance) { FactoryGirl.create(:activity_type, name: 'maintenance') }

    let(:project) { FactoryGirl.create(:project, name: 'project x') }

    let!(:upgrade_hard_disk) { FactoryGirl.create(:activity, user: user, duration: 2.hours, activity_type: support, customer: swag_ag, project: project, date: '2010-01-01', billable: false, reviewed: true) }
    let!(:reboot_server) { FactoryGirl.create(:activity, user: user, duration: 5.minutes, activity_type: maintenance, customer: swag_ag, date: '2010-01-01', billable: true) }
    let!(:swap_ram_module) { FactoryGirl.create(:activity, user: user, duration: 30.minutes, activity_type: support, customer: yolo_inc, date: '2010-01-01', billable: true, reviewed: true) }
    let!(:exchange_power_supply) { FactoryGirl.create(:activity, user: user, duration: 15.minutes, activity_type: support, customer: yolo_inc, date: '2010-01-01', billable: true, reviewed: true, billed: true) }
    let!(:other_year) { FactoryGirl.create(:activity, user: user, duration: 60.minutes, activity_type: support, customer: yolo_inc, date: '2011-01-01', billable: true, reviewed: true, billed: true) }

    describe 'index' do
      context 'as admin' do
        before do
          test_sign_in admin
        end

        it 'shows the correct sums grouped by activity type' do
          get :index, start_date: '2010-01-01', end_date: '2010-01-31', group_by: 'activity_type'
          assigns(:sums).should == { "support" => { "not_billable" => 7200, "duration" => 9900, "billable" => 2700 } }
        end

        it 'shows the correct sums grouped by customer' do
          get :index, start_date: '2010-01-01', end_date: '2010-01-31', group_by: 'customer'
          assigns(:sums).should == { "swag ag" => { "not_billable" => 7200, "duration" => 7200 },
                                     "yolo inc" => { "billable" => 2700, "duration" => 2700 } }
        end

        it 'shows the correct sums grouped by project' do
          get :index, start_date: '2010-01-01', end_date: '2010-01-31', group_by: 'project'
          assigns(:sums).should == { "project x" => { "not_billable" => 7200, "duration" => 9900, "billable" => 2700 } }
        end
      end
    end
  end
end
