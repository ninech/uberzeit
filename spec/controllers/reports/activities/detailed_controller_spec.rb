require 'spec_helper'


describe Reports::Activities::DetailedController do

  let(:team) { FactoryGirl.create(:team) }

  let(:user) { FactoryGirl.create(:user, teams: [team]) }
  let(:team_leader) { FactoryGirl.create(:team_leader, teams: [team]) }
  let(:accountant) { FactoryGirl.create(:accountant) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:swag_ag) { FactoryGirl.create(:customer, name: 'swag ag') }
  let(:yolo_inc) { FactoryGirl.create(:customer, name: 'yolo inc') }

  describe 'access' do
    context 'for non-signed in users' do
      it 'redirects to login' do
        get :index, start_date: '2010-01-01', end_date: '2010-01-31', customer_id: swag_ag.id
        response.should redirect_to(new_session_path)
      end
    end

    context 'for signed-in users' do
      before do
        test_sign_in user
      end

      describe 'GET "index"' do
        it 'denies access' do
          expect { get :index, start_date: '2010-01-01', end_date: '2010-01-31', customer_id: swag_ag.id }.to raise_error(CanCan::AccessDenied)
        end
      end
    end

    context 'for signed-in teamleaders' do
      before do
        test_sign_in team_leader
      end

      describe 'GET "index"' do
        it 'grants access' do
          expect { get :index, start_date: '2010-01-01', end_date: '2010-01-31', customer_id: swag_ag.id }.to_not raise_error(CanCan::AccessDenied)
        end
      end
    end

    context 'for signed-in teamleaders' do
      before do
        test_sign_in accountant
      end

      describe 'GET "index"' do
        it 'grants access' do
          expect { get :index, start_date: '2010-01-01', end_date: '2010-01-31', customer_id: swag_ag.id }.to_not raise_error(CanCan::AccessDenied)
        end
      end
    end

    context 'for signed-in admins' do
      before do
        test_sign_in admin
      end

      describe 'GET "index"' do
        it 'grants access' do
          expect { get :index, start_date: '2010-01-01', end_date: '2010-01-31', customer_id: swag_ag.id }.to_not raise_error(CanCan::AccessDenied)
        end
      end
    end
  end

  describe 'activities' do


    let(:support) { FactoryGirl.create(:activity_type, name: 'support') }
    let(:maintenance) { FactoryGirl.create(:activity_type, name: 'maintenance') }

    let(:project) { FactoryGirl.create(:project, name: 'project x') }

    before do
      FactoryGirl.create(:activity, user: user, duration: 2.hours, activity_type: support, customer: swag_ag, project: project, date: '2010-01-01', billable: false, reviewed: true)
      FactoryGirl.create(:activity, user: user, duration: 5.minutes, activity_type: maintenance, customer: swag_ag, date: '2010-01-01', billable: true)
      FactoryGirl.create(:activity, user: user, duration: 55.minutes, activity_type: maintenance, customer: swag_ag, date: '2010-01-05', billable: true, reviewed: true, billed: true)
      FactoryGirl.create(:activity, user: user, duration: 1.hour, activity_type: support, customer: swag_ag, date: '2010-01-10', billable: true, reviewed: true, billed: false)
      FactoryGirl.create(:activity, user: user, duration: 30.minutes, activity_type: support, customer: yolo_inc, date: '2010-01-01', billable: true, reviewed: true)
      FactoryGirl.create(:activity, user: user, duration: 15.minutes, activity_type: support, customer: yolo_inc, date: '2010-01-01', billable: true, reviewed: true, billed: true)
      FactoryGirl.create(:activity, user: user, duration: 60.minutes, activity_type: support, customer: yolo_inc, date: '2011-01-01', billable: true, reviewed: true, billed: true)
    end

    describe 'index' do
      context 'as admin' do
        before do
          test_sign_in admin
        end

        it 'assigns the grouped activities' do
          get :index, start_date: '2010-01-01', end_date: '2010-01-31', customer: swag_ag.display_name
          assigns(:grouped_activities).keys.map{ |type| type.name }.should == ['support', 'maintenance']
          assigns(:grouped_activities).values.first.length.should == 2
          assigns(:grouped_activities).values.second.length.should == 1
        end

        it 'assigns the subtotals' do
          get :index, start_date: '2010-01-01', end_date: '2010-01-31', customer: swag_ag.display_name
          assigns(:subtotals).values.first.should == { "billable" => 3600, "not_billable" => 7200, "billed" => 0 }
          assigns(:subtotals).values.second.should == { "billable" => 3300, "not_billable" => 0, "billed" => 3300 }
        end

        it 'assigns the totals' do
          get :index, start_date: '2010-01-01', end_date: '2010-01-31', customer: swag_ag.display_name
          assigns(:totals).should == { "billable" => 6900, "not_billable" => 7200, "billed" => 3300 }
        end
      end
    end
  end
end
