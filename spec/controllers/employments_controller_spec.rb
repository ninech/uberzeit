require 'spec_helper'

describe EmploymentsController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:employment) { FactoryGirl.create(:employment, user: user) }
  let(:admin) do
    FactoryGirl.create(:user).tap { |user| user.add_role(:admin) }
  end

  context 'for non-signed in users' do
    it 'denies access' do
      expect { get :index, user_id: user.id }.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'for signed-in users' do
    context 'as owner' do
      before do
        test_sign_in user
      end

      describe 'GET "index"' do
        it 'populates an array of employments' do
          get :index, user_id: user.id
          assigns(:employments).should eq(user.employments)
        end

        it 'renders the :index template' do
          get :index, user_id: user.id
          response.should render_template :index
        end
      end
    end

    context 'as admin' do
      before do
        test_sign_in admin
      end

      describe 'GET "new"' do
        it 'assigns a new employment to @employment' do
          get :new, user_id: user.id
          assigns(:employment).class.should be(Employment)
        end

        it 'renders the :new template' do
          get :new, user_id: user.id
          response.should render_template :new
        end
      end

      describe 'GET "edit"' do
        it 'assigns the to-be edited employment to @employment' do
          get :edit, id: employment.id, user_id: user.id
          assigns(:employment).should eq(employment)
        end

        it 'renders the :edit template' do
          get :edit, id: employment.id, user_id: user.id
          response.should render_template :edit
        end
      end

      describe 'PUT "update"' do
        before do
          @employment = FactoryGirl.create(:employment, start_date: '2006-05-05', end_date: '2007-05-05')
        end

        context 'with valid attributes' do
          it 'changes @employment\'s attributes' do
            put :update, id: @employment, user_id: @employment.user, employment: FactoryGirl.attributes_for(:employment, start_date: '2006-06-06', end_date: '2012-12-12')
            @employment.reload
            @employment.start_date.should eq(Date.new(2006,6,6))
            @employment.end_date.should eq(Date.new(2012,12,12))
          end

          it 'redirects to the updated employment' do
            put :update, id: @employment, user_id: @employment.user, employment: FactoryGirl.attributes_for(:employment)
            response.should redirect_to user_employments_path(@employment.user)
          end
        end

        context 'with invalid attributes' do
          it 'does not change @employment\'s attributes' do
            put :update, id: @employment, user_id: @employment.user, employment: FactoryGirl.attributes_for(:employment, start_date: nil)
            @employment.reload
            @employment.start_date.should eq(Date.new(2006,5,5))
          end

          it 're-renders the :edit template' do
            put :update, id: @employment, user_id: @employment.user, employment: FactoryGirl.attributes_for(:invalid_employment)
            response.should render_template :edit
          end
        end
      end

      describe 'POST "create"' do
        before do
          @user = FactoryGirl.create(:user)
        end

        context 'with valid attributes' do
          it 'creates a new employment' do
            expect { post :create, user_id: @user, employment: FactoryGirl.attributes_for(:employment) }.to change(Employment,:count).by(1)
          end

          it 'redirects to the new employment' do
            post :create, user_id: @user, employment: FactoryGirl.attributes_for(:employment)
            @user.employments.reload
            response.should redirect_to user_employments_path(@user)
          end
        end

        context 'with invalid attributes' do
          it 'does not save the new employment' do
            expect { post :create, user_id: @user, employment: FactoryGirl.attributes_for(:invalid_employment) }.to_not change(Employment,:count)
          end

          it 're-renders the :new template' do
            post :create, user_id: @user, employment: FactoryGirl.attributes_for(:invalid_employment)
            response.should render_template :new
          end
        end
      end


      describe 'DELETE "destroy"' do
        before do
          FactoryGirl.create(:employment) # create another because we can't delete the last one
          @employment = FactoryGirl.create(:employment)
        end

        it 'deletes the entry' do
          expect { delete :destroy, id: @employment, user_id: @employment.user }.to change(Employment,:count).by(-1)
        end

        it 'redirects to the overview' do
          delete :destroy, id: @employment, user_id: @employment.user
          response.should redirect_to user_employments_path(@employment.user)
        end
      end
    end
  end
end
