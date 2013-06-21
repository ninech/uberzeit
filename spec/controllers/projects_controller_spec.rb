require 'spec_helper'

describe ProjectsController do

  let(:project) { FactoryGirl.create(:project) }
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

      it 'assigns the available projects grouped by customer' do
        customer1 = FactoryGirl.create(:customer)
        customer2 = FactoryGirl.create(:customer)
        project1 = FactoryGirl.create(:project, customer: customer1)
        project2 = FactoryGirl.create(:project, customer: customer2)

        get :index
        assigns(:projects).should eq({customer1 => [project1], customer2 => [project2]})
      end
    end

    describe 'POST "create"' do
      context 'with valid attributes' do
        it 'creates a new project' do
          expect { post :create, project: FactoryGirl.attributes_for(:project, customer_id: customer.id) }.to change(Project,:count).by(1)
        end

        it 'redirects to the overview' do
          post :create, project: FactoryGirl.attributes_for(:project, customer_id: customer.id)
          response.should redirect_to projects_path
        end
      end

      context 'with invalid attributes' do
        it 'does not save the new project' do
          expect { post :create, project: FactoryGirl.attributes_for(:project, name: '') }.to_not change(Project,:count)
        end

        it 're-renders the :new template' do
          post :create, project: FactoryGirl.attributes_for(:project, name: '')
          response.should render_template :new
        end
      end
    end

    describe 'GET "edit"' do
      it 'assigns the to-be edited project to @project' do
        get :edit, id: project.id
        assigns(:project).should eq(project)
      end

      it 'renders the :edit template' do
        get :edit, id: project.id
        response.should render_template :edit
      end
    end

    describe 'PUT "update"' do
      context 'with valid attributes' do
        it 'changes project\'s attributes' do
          expect {
            put :update, id: project, project: FactoryGirl.attributes_for(:project, name: 'Project 1337')
            project.reload
          }.to change(project, :name).to('Project 1337')
        end

        it 'redirects to the overview' do
          put :update, id: project, project: FactoryGirl.attributes_for(:project)
          response.should redirect_to projects_path
        end
      end

      context 'with invalid attributes' do
        it 'does not change project\'s attributes' do
          expect {
            put :update, id: project, project: FactoryGirl.attributes_for(:project, name: nil)
            project.reload
          }.not_to change(project, :name)
        end

        it 're-renders the :edit template' do
          put :update, id: project, project: FactoryGirl.attributes_for(:project, name: nil)
          response.should render_template :edit
        end
      end
    end

    describe 'DELETE "destroy"' do
      it 'deletes the entry' do
        project
        expect { delete :destroy, id: project }.to change(Project,:count).by(-1)
      end

      it 'redirects to the overview' do
        delete :destroy, id: project
        response.should redirect_to projects_path
      end
    end
  end

end
