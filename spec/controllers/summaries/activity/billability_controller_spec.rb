require 'spec_helper'


describe Summaries::Activity::BillabilityController do


  let(:team) { FactoryGirl.create(:team) }

  let(:user) { FactoryGirl.create(:user, teams: [team]) }
  let(:team_leader) { FactoryGirl.create(:team_leader, teams: [team]) }
  let(:admin) { FactoryGirl.create(:admin) }

  describe 'access' do
    context 'for non-signed in users' do
      it 'redirects to login' do
        get :index
        response.should redirect_to(new_session_path)
      end
    end

    context 'for signed-in users' do
      before do
        test_sign_in user
      end

      describe 'GET "index"' do
        it 'denies access' do
          get :index
          response.status.should == 403
        end
      end
    end

    context 'for signed-in teamleaders' do
      before do
        test_sign_in team_leader
      end

      describe 'GET "index"' do
        it 'grant access' do
          get :index
          response.status.should == 200
        end
      end
    end

    context 'for signed-in admins' do
      before do
        test_sign_in admin
      end

      describe 'GET "index"' do
        it 'grant access' do
          get :index
          response.status.should == 200
        end
      end
    end
  end

  describe 'activities' do

    let(:user_of_another_team) { FactoryGirl.create(:user) }

    let(:swag_ag) { FactoryGirl.create(:customer) }
    let(:yolo_inc) { FactoryGirl.create(:customer) }

    let(:support) { FactoryGirl.create(:activity_type) }
    let(:maintenance) { FactoryGirl.create(:activity_type) }

    let!(:upgrade_hard_disk) { FactoryGirl.create(:activity, user: user, duration: 2.hours, activity_type: support, customer: swag_ag) }
    let!(:reboot_server) { FactoryGirl.create(:activity, user: user, duration: 5.minutes, activity_type: maintenance, customer: swag_ag) }
    let!(:swap_ram_module) { FactoryGirl.create(:activity, user: user, duration: 30.minutes, activity_type: support, customer: yolo_inc) }

    let!(:activity4) { FactoryGirl.create(:activity, user: user_of_another_team, duration: 30.minutes) }

    describe 'index' do
      context 'as teamleader' do
        before do
          test_sign_in team_leader
        end

        it 'loads the activities of the team members' do
          get :index
          assigns(:activities).should =~ [upgrade_hard_disk, reboot_server, swap_ram_module]
        end

        it 'groups the activities by customer and type' do
          get :index
          assigns(:grouped_activities).should eq(swag_ag => {support => [upgrade_hard_disk], maintenance => [reboot_server]}, yolo_inc => {support => [swap_ram_module]})
        end

        it 'does not load locked activities'
      end

      context 'as admin' do
        before do
          test_sign_in admin
        end

        it 'loads all activities' do
          get :index
          assigns(:activities).should =~ [upgrade_hard_disk, reboot_server, swap_ram_module, activity4]
        end
      end
    end

    describe 'submit' do
      before do
        test_sign_in team_leader
      end

      it 'locks all submitted activities'
      it 'won\'t lock submitted activities of non-team members (security check)'
    end
  end
end
