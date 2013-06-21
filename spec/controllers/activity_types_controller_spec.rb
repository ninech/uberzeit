require 'spec_helper'

describe ActivityTypesController do

  let(:activity_type) { FactoryGirl.create(:activity_type) }
  let(:admin) { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }

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

      it 'assigns the available activity_types' do
        activity_type1 = FactoryGirl.create(:activity_type)
        activity_type2 = FactoryGirl.create(:activity_type)

        get :index
        assigns(:activity_types).should eq([activity_type1, activity_type2])
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        it 'creates a new activity_type' do
          expect { post :create, activity_type: FactoryGirl.attributes_for(:activity_type) }.to change(ActivityType,:count).by(1)
        end

        it 'redirects to the overview' do
          post :create, activity_type: FactoryGirl.attributes_for(:activity_type)
          response.should redirect_to activity_types_path
        end
      end

      context 'with invalid attributes' do
        it 'does not save the new activity_type' do
          expect { post :create, activity_type: FactoryGirl.attributes_for(:activity_type, name: '') }.to_not change(ActivityType,:count)
        end

        it 're-renders the :new template' do
          post :create, activity_type: FactoryGirl.attributes_for(:activity_type, name: '')
          response.should render_template :new
        end
      end
    end

    describe 'GET "edit"' do
      it 'assigns the to-be edited activity_type to @activity_type' do
        get :edit, id: activity_type.id
        assigns(:activity_type).should eq(activity_type)
      end

      it 'renders the :edit template' do
        get :edit, id: activity_type.id
        response.should render_template :edit
      end
    end

    describe 'PUT "update"' do
      context 'with valid attributes' do
        it 'changes activity_type\'s attributes' do
          expect {
            put :update, id: activity_type, activity_type: FactoryGirl.attributes_for(:activity_type, name: 'ActivityType 1337')
            activity_type.reload
          }.to change(activity_type, :name).to('ActivityType 1337')
        end

        it 'redirects to the overview' do
          put :update, id: activity_type, activity_type: FactoryGirl.attributes_for(:activity_type)
          response.should redirect_to activity_types_path
        end
      end

      context 'with invalid attributes' do
        it 'does not change activity_type\'s attributes' do
          expect {
            put :update, id: activity_type, activity_type: FactoryGirl.attributes_for(:activity_type, name: nil)
            activity_type.reload
          }.not_to change(activity_type, :name)
        end

        it 're-renders the :edit template' do
          put :update, id: activity_type, activity_type: FactoryGirl.attributes_for(:activity_type, name: nil)
          response.should render_template :edit
        end
      end
    end

    describe 'DELETE "destroy"' do
      it 'deletes the entry' do
        activity_type
        expect { delete :destroy, id: activity_type }.to change(ActivityType,:count).by(-1)
      end

      it 'redirects to the overview' do
        delete :destroy, id: activity_type
        response.should redirect_to activity_types_path
      end
    end
  end

end
