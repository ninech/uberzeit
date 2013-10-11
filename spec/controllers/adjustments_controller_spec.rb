require 'spec_helper'

describe AdjustmentsController do
  render_views

  let(:adjustment) { FactoryGirl.create(:adjustment) }
  let(:time_type) { TEST_TIME_TYPES[:work] }
  let(:admin) { FactoryGirl.create(:admin) }

  context 'for non-signed in users' do
    it 'redirects to login' do
      get :index
      response.should redirect_to(new_session_path)
    end
  end

  context 'for signed-in users' do
    context 'as admin' do
      before do
        test_sign_in admin
      end

      describe 'GET "new"' do
        it 'assigns a new adjustment to @adjustment' do
          get :new
          assigns(:adjustment).should be_kind_of(Adjustment)
        end

        it 'renders the :new template' do
          get :new
          response.should render_template :new
        end
      end

      describe 'GET "index"' do
        it 'assigns the adjustments to to @adjustments' do
          get :index
          assigns(:adjustments).should_not be_nil
        end

        it 'renders the :index template' do
          get :index
          response.should render_template :index
        end
      end

      describe 'GET "edit"' do
        it 'assigns the to-be edited adjustment to @adjustment' do
          get :edit, id: adjustment.id
          assigns(:adjustment).should eq(adjustment)
        end

        it 'renders the :edit template' do
          get :edit, id: adjustment.id
          response.should render_template :edit
        end
      end

      describe 'PUT "update"' do
        context 'with valid attributes' do
          it 'changes adjustment\'s attributes' do
            expect {
              put :update, id: adjustment, adjustment: FactoryGirl.attributes_for(:adjustment, label: 'Adjustment Lala')
              adjustment.reload
            }.to change(adjustment, :label).to('Adjustment Lala')
          end

          it 'redirects to the overview' do
            put :update, id: adjustment, adjustment: FactoryGirl.attributes_for(:adjustment)
            response.should redirect_to adjustments_path
          end
        end

        context 'with invalid attributes' do
          it 'does not change adjustment\'s attributes' do
            expect {
              put :update, id: adjustment, adjustment: FactoryGirl.attributes_for(:invalid_adjustment, label: nil)
              adjustment.reload
            }.not_to change(adjustment, :label)
          end

          it 're-renders the :edit template' do
            put :update, id: adjustment, adjustment: FactoryGirl.attributes_for(:invalid_adjustment)
            response.should render_template :edit
          end
        end
      end

      describe 'POST "create"' do
        context 'with valid attributes' do
          it 'creates a new adjustment' do
            expect { post :create, adjustment: FactoryGirl.attributes_for(:adjustment, user_id: admin, time_type_id: time_type ) }.to change(Adjustment,:count).by(1)
          end

          it 'redirects to the overview' do
            post :create, adjustment: FactoryGirl.attributes_for(:adjustment, user_id: admin, time_type_id: time_type)
            response.should redirect_to adjustments_path
          end
        end

        context 'with invalid attributes' do
          it 'does not save the new adjustment' do
            expect { post :create, adjustment: FactoryGirl.attributes_for(:invalid_adjustment, user_id: admin, time_type_id: time_type) }.to_not change(Adjustment,:count)
          end

          it 're-renders the :new template' do
            post :create, adjustment: FactoryGirl.attributes_for(:invalid_adjustment, user_id: admin, time_type_id: time_type)
            response.should render_template :new
          end
        end
      end


      describe 'DELETE "destroy"' do
        it 'deletes the entry' do
          adjustment
          expect { delete :destroy, id: adjustment }.to change(Adjustment,:count).by(-1)
        end

        it 'redirects to the overview' do
          delete :destroy, id: adjustment
          response.should redirect_to adjustments_path
        end
      end
    end
  end
end
