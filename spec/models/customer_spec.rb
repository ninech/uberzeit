# == Schema Information
#
# Table name: customers
#
#  id           :integer          primary key
#  name         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  abbreviation :string(255)
#

require 'spec_helper'

describe Customer do
  subject { FactoryGirl.create(:customer) }

  its(:abbreviation) { should eq('yolo') }
  its(:display_name) { should eq("#{subject.number}: Yolo Inc. - yolo") }

  context 'without abbreviation' do
    before do
      subject.abbreviation = nil
    end
    its(:abbreviation) { should be_nil }
    its(:display_name) { should eq("#{subject.number}: Yolo Inc.")}
  end

  context 'when the abbreviation is the same as the name' do
    before do
      subject.abbreviation = subject.name
    end
    its(:abbreviation) { should eq('Yolo Inc.') }
    its(:display_name) { should eq("#{subject.number}: Yolo Inc.") }
  end
end
