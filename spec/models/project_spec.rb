require 'spec_helper'

describe Project do
  describe 'validations' do
    let(:project) { Project.new }

    it 'it does not accept a blank name' do
      project.name = ''
      project.should_not be_valid
      project.should have(1).errors_on(:name)
    end
  end
end

