require 'spec_helper'

describe API::Resources::Projects do
  include Warden::Test::Helpers

  let(:api_user) { FactoryGirl.create(:user) }
  let(:json) { JSON.parse(response.body) }

  shared_examples 'a project' do
    its(['id']) { should be_present }
    its(['customer_id']) { should be_present }
    its(['name']) { should be_present }
  end

  before do
    login_as api_user
  end

  describe 'GET /api/customers/2/projects' do
    let!(:customer) { FactoryGirl.create(:customer, id: 2) }
    let!(:project1) { FactoryGirl.create(:project, customer: customer) }
    let!(:project2) { FactoryGirl.create(:project, customer: customer) }

    before do
      get '/api/customers/2/projects'
    end

    it 'returns a list of the projects' do
      json.should have(2).projects
    end

    it_behaves_like 'a project' do
      subject { json.first }
    end
  end

end


