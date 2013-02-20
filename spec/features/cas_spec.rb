require 'spec_helper'

describe 'RackCAS' do
  describe 'when not logged in' do
    it 'redirects to the CAS page' do
      visit '/'
      page.body.should have_css('title', text: 'Fake CAS')
    end
  end
end
