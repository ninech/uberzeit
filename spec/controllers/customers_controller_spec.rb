require 'spec_helper'

describe CustomersController do
  render_views

  let!(:admin) { FactoryGirl.create(:admin) }
  let(:valid_customer_attributes) { { name: 'Nine Internet Solutions AG', abbreviation: 'nine.ch', number: 9999 } }
  let!(:customer) { FactoryGirl.create :customer }

  context 'for non-signed in users' do
    describe 'GET "index"' do
      it 'redirects to login' do
        get :index
        response.should redirect_to(new_session_path)
      end
    end

    describe 'GET "edit"' do
      it 'redirects to login' do
        get :edit, id: customer.id
        response.should redirect_to(new_session_path)
      end
    end

    describe 'GET "new"' do
      it 'redirects to login' do
        get :new
        response.should redirect_to(new_session_path)
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        it 'redirects to login' do
          post :create, customer: valid_customer_attributes
          response.should redirect_to(new_session_path)
        end

        it 'does create a customer' do
          expect do
            post :create, customer: valid_customer_attributes
          end.not_to change(Customer, :count)
        end
      end
    end

    describe 'PUT "update"' do
      context 'with valid attributes' do
        it 'redirects to login' do
          put :update, id: customer.id, name: 'Babo'
          response.should redirect_to(new_session_path)
        end

        it 'does not change any attributes' do
          put :update, id: customer.id, name: 'Babo'
          customer.name.should_not == 'Babo'
        end
      end
    end

    describe 'DELETE "destroy"' do
      it 'redirects to login' do
        delete :destroy, id: customer.id
        response.should redirect_to(new_session_path)
      end

      it 'does not delete the customer' do
        expect do
          delete :destroy, id: customer.id
        end.to_not change(Customer, :count)
      end
    end
  end

  context 'for signed-in admins' do
    before do
      test_sign_in admin
    end

    describe 'GET "edit"' do
      it 'assigns the to-be edited customer to @customer' do
        get :edit, id: customer.id
        assigns(:customer).should eq(customer)
      end

      it 'renders the :edit template' do
        get :edit, id: customer.id
        response.should render_template :edit
      end
    end

    describe 'GET "index"' do
      it 'assigns the customers to @customers' do
        get :index
        assigns(:customers).should eq(Customer.all)
      end

      it 'renders the :index template' do
        get :index
        response.should render_template :index
      end
    end

    describe 'GET "new"' do
      it 'assigns the to-be edited customer to @customer' do
        get :new
        assigns(:customer).id.should be_nil
      end

      it 'renders the :new template' do
        get :new
        response.should render_template :new
      end
    end

    describe 'PUT "update"' do
      context 'with valid attributes' do
        it 'changes customer\'s attributes' do
          expect {
            put :update, id: customer.id, customer: valid_customer_attributes
            customer.reload
          }.to change(customer, :name).to(valid_customer_attributes[:name])
        end

        it 'redirects to the overview' do
          put :update, id: customer.id, customer: valid_customer_attributes
          response.should redirect_to customers_path
        end
      end

      context 'with invalid attributes' do
        it 'does not change customer\'s attributes' do
          expect {
            put :update, id: customer.id, customer: { name: '' }
            customer.reload
          }.not_to change(customer, :name)
        end

        it 're-renders the :edit template' do
          put :update, id: customer.id, customer: { name: '' }
          response.should render_template :edit
        end
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        it 'creates a customer' do
          expect {
            post :create, customer: valid_customer_attributes
          }.to change(Customer, :count)
        end

        it 'redirects to the overview' do
          post :create, customer: valid_customer_attributes
          response.should redirect_to customers_path
        end
      end

      context 'with invalid attributes' do
        it 'does not create a customer' do
          expect {
            post :create, customer: { name: '' }
          }.not_to change(Customer, :count)
        end

        it 're-renders the :edit template' do
          post :create, customer: { name: '' }
          response.should render_template :new
        end
      end
    end

    describe 'DELETE "destroy"' do
      it 'does delete a customer' do
        expect do
          delete :destroy, id: customer.id
        end.to change(Customer, :count).by(-1)
      end

      it 'does delete the customer' do
        delete :destroy, id: customer.id
        Customer.where(id: customer.id).count.should == 0
      end
    end

  end
end
