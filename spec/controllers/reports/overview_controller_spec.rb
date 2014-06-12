require 'spec_helper'

describe Reports::OverviewController do

  let(:user) { FactoryGirl.create(:user) }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :index, user_id: user
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do
    before do
      User.stub(:find) do |*args|
        if args.first.to_i == user.id
          user
        else
          User.find_by_id(args.first)
        end
      end
    end

    shared_examples_for "assigned vars" do
      it 'assigns overtime' do
        user.time_sheet.stub(:overtime).and_return(10)
        get :index, user_id: user
        assigns(:uberzeit).should eq(10)
      end

      it 'assigns month_total_work' do
        user.time_sheet.stub(:overtime).and_return(10)
        user.time_sheet.stub(:planned_working_time).and_return(10)
        get :index, user_id: user
        assigns(:month_total_work).should eq(20)
      end

      it 'assigns month_percent_done' do
        user.time_sheet.stub(:planned_working_time).and_return(20)
        get :index, user_id: user
        assigns(:month_percent_done).should eq(0)
      end

      describe 'absences' do
        before do
          FindDailyAbsences.stub(:new).and_return(OpenStruct.new(result_grouped_by_date: []))
        end

        it 'assigns personal_absences' do
          FindDailyAbsences.should_receive(:new).with(user, Date.today..Date.today+7.days).and_return(OpenStruct.new(result_grouped_by_date: []))
          get :index, user_id: user
          assigns(:personal_absences).should eq([])
        end

        it 'assigns team_absences' do
          FindDailyAbsences.should_receive(:new).with([], Date.today..Date.today+7.days).and_return(OpenStruct.new(result_grouped_by_date: []))
          get :index, user_id: user
          assigns(:team_absences).should eq([])
        end
      end

      it 'assigns vacation_redeemed' do
        user.time_sheet.stub(:redeemed_vacation).and_return(5)
        get :index, user_id: user
        assigns(:vacation_redeemed).should eq(5)
      end

      it 'assigns vacation_remaining' do
        user.time_sheet.stub(:remaining_vacation).and_return(15)
        get :index, user_id: user
        assigns(:vacation_remaining).should eq(15)
      end
    end


    context 'current user' do
      before do
        test_sign_in user
      end

      describe 'GET "index"' do
        it_behaves_like "assigned vars"

        it 'renders the :index template' do
          get :index, user_id: user
          response.should render_template :index
        end

        context 'with no planned work' do
          before(:each) do
            TimeSheet.any_instance.stub(:planned_working_time).and_return(0)
          end

          it 'does not raise an error' do
            expect do
              get :index, user_id: user
            end.not_to raise_error
          end
        end

        context 'on 1st january' do
          before { Timecop.freeze('2014-01-01'.to_date) }

          it 'does not raise an error' do
            expect { get :index, user_id: user }.to_not raise_error
          end
        end
      end
    end


    context 'other user' do
      let(:admin) { FactoryGirl.create(:admin) }

      before do
        test_sign_in admin
      end

      describe 'GET "index"' do
        it_behaves_like "assigned vars"
      end
    end
  end
end
