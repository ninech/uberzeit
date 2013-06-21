require 'spec_helper'

describe Project do
  it 'has a valid factory' do
    FactoryGirl.build(:project).should be_valid
  end

  it 'acts as paranoid' do
    entry = FactoryGirl.create(:project)
    entry.destroy
    expect { Project.find(entry.id) }.to raise_error
    expect { Project.with_deleted.find(entry.id) }.to_not raise_error
  end

  describe 'validations' do
    let(:project) { Project.new }

    it 'it does not accept a blank name' do
      project.name = ''
      project.should_not be_valid
      project.should have(1).errors_on(:name)
    end
  end
end

