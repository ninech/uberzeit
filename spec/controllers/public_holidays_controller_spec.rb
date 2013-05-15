require 'spec_helper'

describe PublicHolidaysController do
  render_views

  let(:user) { FactoryGirl.create(:user) }
  let(:public_holiday) { FactoryGirl.create(:public_holiday) }
  let(:admin) do
    FactoryGirl.create(:user).tap { |user| user.add_role(:admin) }
  end

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
        it 'assigns a new public holiday to @public_holiday' do
          get :new
          assigns(:public_holiday).class.should be(PublicHoliday)
        end

        it 'renders the :new template' do
          get :new
          response.should render_template :new
        end
      end

      describe 'GET "index"' do
        it 'assigns the publci holidays to to @public_holidays' do
          get :index
          assigns(:public_holidays).should_not be_nil
        end

        it 'assigns the year to @year' do
          get :index
          assigns(:year).should be(Time.current.year)
        end

        it 'renders the :index template' do
          get :index
          response.should render_template :index
        end
      end

      describe 'GET "edit"' do
        it 'assigns the to-be edited public holiday to @public_holiday' do
          get :edit, id: public_holiday.id
          assigns(:public_holiday).should eq(public_holiday)
        end

        it 'renders the :edit template' do
          get :edit, id: public_holiday.id
          response.should render_template :edit
        end
      end

      describe 'PUT "update"' do
        context 'with valid attributes' do
          it 'changes public_holiday\'s attributes' do
            put :update, id: public_holiday, public_holiday: FactoryGirl.attributes_for(:public_holiday, name: 'New Public Holiday Name')
            public_holiday.reload
            public_holiday.name.should eq('New Public Holiday Name')
          end

          it 'redirects to the overview' do
            put :update, id: public_holiday, public_holiday: FactoryGirl.attributes_for(:public_holiday)
            response.should redirect_to public_holidays_path
          end
        end

        context 'with invalid attributes' do
          it 'does not change public_holiday\'s attributes' do
            name_before = public_holiday.name.dup
            put :update, id: public_holiday, public_holiday: FactoryGirl.attributes_for(:invalid_public_holiday, name: nil)
            public_holiday.reload
            public_holiday.name.should eq(name_before)
          end

          it 're-renders the :edit template' do
            put :update, id: public_holiday, public_holiday: FactoryGirl.attributes_for(:invalid_public_holiday)
            response.should render_template :edit
          end
        end
      end

      describe 'POST "create"' do
        context 'with valid attributes' do
          it 'creates a new public holiday' do
            expect { post :create, public_holiday: FactoryGirl.attributes_for(:public_holiday) }.to change(PublicHoliday,:count).by(1)
          end

          it 'redirects to the overview' do
            post :create, public_holiday: FactoryGirl.attributes_for(:public_holiday)
            response.should redirect_to public_holidays_path
          end
        end

        context 'with invalid attributes' do
          it 'does not save the new public holiday' do
            expect { post :create, public_holiday: FactoryGirl.attributes_for(:invalid_public_holiday) }.to_not change(PublicHoliday,:count)
          end

          it 're-renders the :new template' do
            post :create, public_holiday: FactoryGirl.attributes_for(:invalid_public_holiday)
            response.should render_template :new
          end
        end
      end


      describe 'DELETE "destroy"' do
        it 'deletes the entry' do
          public_holiday
          expect { delete :destroy, id: public_holiday }.to change(PublicHoliday,:count).by(-1)
        end

        it 'redirects to the overview' do
          delete :destroy, id: public_holiday
          response.should redirect_to public_holidays_path
        end
      end
    end
  end
end
