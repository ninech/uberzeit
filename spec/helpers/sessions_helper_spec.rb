require 'spec_helper'

describe SessionsHelper do

  let(:user) { FactoryGirl.create(:user) }

  it 'sets the session when signing in' do
    user
    expect { helper.sign_in(user) }.to change { session[:user_id] }
  end

end
