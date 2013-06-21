require 'spec_helper'

describe ProjectsController do

  let(:admin) { FactoryGirl.create(:admin) }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :index
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in admin
    end

    describe "GET 'index'" do
      it "returns http success" do
        get 'index'
        response.should be_success
      end

      it 'assigns the available projects grouped by customer' do
        customer1 = FactoryGirl.create(:customer)
        customer2 = FactoryGirl.create(:customer)
        project1 = FactoryGirl.create(:project, customer: customer1)
        project2 = FactoryGirl.create(:project, customer: customer2)

        get :index
        assigns(:projects).should eq({customer1 => [project1], customer2 => [project2]})
      end
    end

    describe "GET 'create'" do
      it "returns http success" do
        get 'create'
        response.should be_success
      end
    end

    describe "GET 'update'" do
      it "returns http success" do
        get 'update'
        response.should be_success
      end
    end

    describe "GET 'destroy'" do
      it "returns http success" do
        get 'destroy'
        response.should be_success
      end
    end
  end

end
