require 'spec_helper'

describe UberZeit::TimeTypeCalculators::Dummy do

  describe 'class' do
    subject { UberZeit::TimeTypeCalculators::Dummy }
    its(:factor) { should eq(0.0) }
    its(:description) { should be_instance_of(String) }
    its(:name) { should be_instance_of(String) }
  end

  describe 'instance' do
    subject { UberZeit::TimeTypeCalculators::Dummy.new }

    its(:result) { should eq(0) }
  end

end
