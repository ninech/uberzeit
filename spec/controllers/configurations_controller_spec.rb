require 'spec_helper'

describe ConfigurationsController do
  render_views

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :edit
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed in users' do
    before do
      test_sign_in FactoryGirl.create(:user)
    end

    it 'denies access' do
      expect { get :edit }.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'for signed in admins' do
    before do
      test_sign_in FactoryGirl.create(:admin)
    end

    describe 'GET "edit"' do
      it 'renders the edit template' do
        get :edit
        response.should render_template :edit
      end
    end

    describe 'PUT "update"' do
      it 'changes the settings' do
        put :update, configuration: { vacation_per_year_days: 30, work_per_day_hours: 10 }
        expect(Setting.vacation_per_year_days).to eq(30)
        expect(Setting.work_per_day_hours).to eq(10)
      end

      context 'if work_per_day_hours does not change' do
        it 'does not flush the cache' do
          expect(Day).to_not receive(:delete_all)
          put :update, configuration: { work_per_day_hours: Setting.work_per_day_hours.to_s }
        end
      end

      context 'if work_per_day_hours changes' do
        it 'flushes the cache' do
          expect(Day).to receive(:delete_all)
          put :update, configuration: { work_per_day_hours: 9 }
        end
      end
    end
  end
end
