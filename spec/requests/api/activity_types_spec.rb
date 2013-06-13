require 'spec_helper'

describe API::Resources::ActivityTypes do
  include ApiHelpers

  let(:api_user) { FactoryGirl.create(:user) }
  let(:parsed_json) { JSON.parse(response.body) }

  shared_examples 'an activity_type' do
    its(['id']) { should be_present }
    its(['name']) { should be_present }
  end

  describe 'GET /api/activity_types' do
    let!(:activity_type) { FactoryGirl.create(:activity_type) }

    before do
      auth_get '/api/activity_types'
    end

    it 'returns a list of activity types' do
      parsed_json.should have(1).items
    end

    it_behaves_like 'an activity_type' do
      subject { parsed_json.first }
    end
  end

end
