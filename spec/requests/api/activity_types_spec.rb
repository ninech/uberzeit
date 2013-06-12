require 'spec_helper'

describe API::Resources::ActivityTypes do
  include ApiHelpers

  let(:api_user) { FactoryGirl.create(:user) }
  let(:parsed_json) { JSON.parse(response.body) }

  describe 'GET /api/activity_types' do
    let!(:activity_type) { FactoryGirl.create(:activity_type) }

    before do
      auth_get '/api/activity_types'
    end

    it 'returns a list of activity types' do
      parsed_json.should have(1).items
    end

    describe 'attributes' do
      subject { parsed_json.first }

      its(['id']) { should eq(activity_type.id) }
      its(['name']) { should eq(activity_type.name) }
    end
  end

end
