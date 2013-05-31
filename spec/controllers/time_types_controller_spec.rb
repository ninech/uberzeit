require 'spec_helper'

describe TimeTypesController do
  render_views

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :index
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in FactoryGirl.create(:admin)
    end

    describe 'GET "index"' do
      it 'populates an array of time types' do
        get :index
        assigns(:time_types).sort.should eq(TEST_TIME_TYPES.values.sort)
      end

      it 'renders the :index template' do
        get :index
        response.should render_template :index
      end
    end

    describe 'GET "new"' do
      it 'assigns a new time type to @time_type' do
        get :new
        assigns(:time_type).class.should be(TimeType)
      end

      it 'renders the :new template' do
        get :new
        response.should render_template :new
      end
    end

    describe 'GET "edit"' do
      before do
        @time_type = TEST_TIME_TYPES[:work]
      end

      it 'assigns the to-be edited time type to @time_type' do
        get :edit, id: @time_type
        assigns(:time_type).should eq(@time_type)
      end

      it 'renders the :edit template' do
        get :edit, id: @time_type
        response.should render_template :edit
      end
    end

    describe 'PUT "update"' do
      before do
        @time_type = FactoryGirl.create(:time_type, name: 'Work')
      end

      context 'with valid attributes' do
        it 'changes @time_type\'s attributes' do
          put :update, id: @time_type, time_type: FactoryGirl.attributes_for(:time_type, name: 'Chilling out')
          @time_type.reload
          @time_type.name.should eq('Chilling out')
        end

        it 'redirects to the updated time type' do
          put :update, id: @time_type, time_type: FactoryGirl.attributes_for(:time_type)
          response.should redirect_to time_types_path
        end
      end

      context 'with invalid attributes' do
        it 're-renders the :edit template' do
          put :update, id: @time_type, time_type: FactoryGirl.attributes_for(:invalid_time_type)
          response.should render_template :edit
        end
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        it 'creates a new time type' do
          expect { post :create, time_type: FactoryGirl.attributes_for(:time_type) }.to change(TimeType,:count).by(1)
        end

        it 'redirects to the new time type' do
          post :create, time_type: FactoryGirl.attributes_for(:time_type)
          response.should redirect_to time_types_path
        end
      end

      context 'with invalid attributes' do
        it 'does not save the new time type' do
          expect { post :create, time_type: FactoryGirl.attributes_for(:invalid_time_type) }.to_not change(TimeType,:count)
        end

        it 're-renders the :new template' do
          post :create, time_type: FactoryGirl.attributes_for(:invalid_time_type)
          response.should render_template :new
        end
      end
    end

    describe 'DELETE "destroy"' do
      before do
        @time_type = FactoryGirl.create(:time_type)
      end

      it 'deletes the entry' do
        expect { delete :destroy, id: @time_type }.to change(TimeType,:count).by(-1)
      end

      it 'redirects to the overview' do
        delete :destroy, id: @time_type
        response.should redirect_to time_types_path
      end
    end
  end
end
