require 'spec_helper'

describe 'Authentication for App API' do

  it 'disallows connection attempts when no SSL_CLIENT_VERIFY env var is set' do
    get '/api/app/ping', {}, {}
    response.status.should eq(401)
  end

  it 'disallows connection attempts when the client SSL cert was not verified' do
    get '/api/app/ping', {}, { 'SSL_CLIENT_VERIFY' => 'NONE' }
    response.status.should eq(401)
  end

  it 'authenticates when a client SSL cert was verified succesfully' do
    get '/api/app/ping', {}, { 'SSL_CLIENT_VERIFY' => 'SUCCESS' }
    response.status.should eq(200)
  end

end
