require 'spec_helper'

describe Reports::Work::MyWorkController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:year) { 2013 }
  let(:month) { 3 }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :year, user_id: user, year: year
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do

    before do
      test_sign_in user
    end

    describe 'GET "year"' do
      it 'assigns the correct instance variables' do
        get :year, user_id: user, year: year
        assigns(:year).should_not be_nil
        assigns(:buckets).should_not be_nil
      end

      it 'renders the :year template' do
        get :year, user_id: user, year: year
        response.should render_template :year
      end
    end

    describe 'GET "month"' do
      it 'assigns the correct instance variables' do
        get :month, user_id: user, year: year, month: month
        assigns(:year).should_not be_nil
        assigns(:month).should_not be_nil
        assigns(:buckets).should_not be_nil
      end

      it 'generates the correct buckets' do
        get :month, user_id: user, year: year, month: month
        assigns(:buckets).should eq([
          '2013-03-01'.to_date..'2013-03-03'.to_date,
          '2013-03-04'.to_date..'2013-03-10'.to_date,
          '2013-03-11'.to_date..'2013-03-17'.to_date,
          '2013-03-18'.to_date..'2013-03-24'.to_date,
          '2013-03-25'.to_date..'2013-03-31'.to_date
        ])
      end

      it 'renders the :month template' do
        get :month, user_id: user, year: year, month: month
        response.should render_template :month
      end
    end

  end

end
