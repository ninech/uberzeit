require 'spec_helper'

describe API::Resources::Projects do
  include ApiHelpers

  let(:api_user) { FactoryGirl.create(:user) }
  let(:parsed_json) { JSON.parse(response.body) }

  shared_examples 'a project' do
    its(['id']) { should be_present }
    its(['customer_id']) { should be_present }
    its(['name']) { should be_present }
  end

  describe 'GET /api/customers/2/projects' do
    let!(:customer) { FactoryGirl.create(:customer, id: 2) }
    let!(:project1) { FactoryGirl.create(:project, customer: customer) }
    let!(:project2) { FactoryGirl.create(:project, customer: customer) }

    before do
      auth_get '/api/customers/2/projects'
    end

    it 'returns a list of the projects' do
      parsed_json.should have(2).projects
    end

    it_behaves_like 'a project' do
      subject { parsed_json.first }
    end
  end

end


