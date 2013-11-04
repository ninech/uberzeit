require 'spec_helper'


describe Reports::Activities::BillingController do

  let(:user) { FactoryGirl.create(:user) }
  let(:team_leader) { FactoryGirl.create(:team_leader) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:accountant) { FactoryGirl.create(:accountant) }

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
          expect { get :index }.to raise_error(CanCan::AccessDenied)
        end
      end
    end

    context 'for signed-in teamleaders' do
      before do
        test_sign_in team_leader
      end

      describe 'GET "index"' do
        it 'denies access' do
          expect { get :index }.to raise_error(CanCan::AccessDenied)
        end
      end
    end

    context 'for signed-in admins' do
      before do
        test_sign_in admin
      end

      describe 'GET "index"' do
        it 'grant access' do
          expect { get :index }.to_not raise_error(CanCan::AccessDenied)
        end
      end
    end

    context 'for signed-in accountants' do
      before do
        test_sign_in accountant
      end

      describe 'GET "index"' do
        it 'grants access' do
          expect { get :index }.to_not raise_error(CanCan::AccessDenied)
        end
      end
    end
  end

  describe 'activities' do
    let(:swag_ag) { FactoryGirl.create(:customer) }
    let(:yolo_inc) { FactoryGirl.create(:customer) }

    let(:support) { FactoryGirl.create(:activity_type) }
    let(:maintenance) { FactoryGirl.create(:activity_type) }

    let!(:upgrade_hard_disk) { FactoryGirl.create(:activity, user: user, duration: 2.hours, activity_type: support, customer: swag_ag, billable: false) }
    let!(:reboot_server) { FactoryGirl.create(:activity, user: user, duration: 5.minutes, activity_type: maintenance, customer: swag_ag, billable: true) }
    let!(:swap_ram_module) { FactoryGirl.create(:activity, user: user, duration: 30.minutes, activity_type: support, customer: yolo_inc, billable: true, reviewed: true) }
    let!(:exchange_power_supply) { FactoryGirl.create(:activity, user: user, duration: 15.minutes, activity_type: support, customer: yolo_inc, billable: true, reviewed: true, billed: true) }

    describe 'index' do
      context 'as admin' do
        before do
          test_sign_in admin
        end

        it 'loads all yet unbilled activities (billable & reviewed)' do
          get :index
          assigns(:activities).should eq [swap_ram_module]
        end

        context 'with activities without customers' do
          render_views

          let!(:taeja_inc) { FactoryGirl.create(:customer, name: 'TaeJa Inc.', abbreviation: 'taeja') }
          let!(:activity_without_customer) { FactoryGirl.create(:activity, user: user, duration: 2.hours, activity_type: support, customer: taeja_inc, billable: true, reviewed: true) }

          before(:each) do
            taeja_inc.delete
            activity_without_customer.reload
          end

          it 'does not raise an error' do
            expect do
              get :index
            end.to_not raise_error
          end
        end

      end
    end
  end
end
