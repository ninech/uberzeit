require 'spec_helper'

describe API::User::Resources::Customers do
  include Warden::Test::Helpers

  let(:api_user) { FactoryGirl.create(:user) }
  let(:json) { JSON.parse(response.body) }

  shared_examples 'a customer' do
    its(['id']) { should be_present }
    its(['name']) { should be_present }
  end

  before do
    login_as api_user
  end

  describe 'GET /api/customers' do
    let!(:customer1) { FactoryGirl.create(:customer) }
    let!(:customer2) { FactoryGirl.create(:customer) }

    before do
      get '/api/customers'
    end

    it 'returns a list of the customers' do
      json.should have(2).customers
    end

    it_behaves_like 'a customer' do
      subject { json.first }
    end
  end

end
