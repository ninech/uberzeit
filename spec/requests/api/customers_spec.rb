require 'spec_helper'

describe API::Resources::Customers do
  include ApiHelpers

  let(:api_user) { FactoryGirl.create(:user) }
  let(:parsed_json) { JSON.parse(response.body) }

  shared_examples 'a customer' do
    its(['id']) { should be_present }
    its(['name']) { should be_present }
  end

  describe 'GET /api/customers' do
    before do
      auth_get '/api/customers'
    end

    it 'returns a list of the customers' do
      parsed_json.should have(2).customers
    end

    it_behaves_like 'a customer' do
      subject { parsed_json.first }
    end
  end

end

