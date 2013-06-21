require 'spec_helper'

describe CustomerSync do
  let(:customer1) { OpenStruct.new id: 1, companyname: 'Yolo Inc.', firstname: '' }
  let(:customer2) { OpenStruct.new id: 2, companyname: 'Nils Vacuum Cleaners Inc.', firstname: '' }
  let(:customer3) { OpenStruct.new id: 3, companyname: 'Caspar', firstname: 'Nils'}
  let(:customers) { [customer1, customer2, customer3] }

  def sync_customers
    CustomerSync.new.sync
  end

  before do
    CustomerPlugin::Customer.stub(:all) { customers }
  end

  it 'creates a local customer for every remote customer' do
    expect { sync_customers }.to change(Customer, :count).from(0).to(3)
  end

  it 'does not create local customers when they are already synced' do
    sync_customers
    expect { sync_customers }.to_not change(Customer, :count)
  end

  it 'deletes a local customer when the corresponding remote customer was deleted' do
    sync_customers

    customers.delete(customer2)
    expect { sync_customers }.to change(Customer, :count).from(3).to(2)
    expect { Customer.find(customer2.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe 'attributes' do
    before do
      sync_customers
    end

    describe 'customer with a companyname only' do
      subject { Customer.find(1) }
      its(:name) { should eq('Yolo Inc.') }
    end

    describe 'customer with a name and a companyname' do
      subject { Customer.find(3) }
      its(:name) { should eq('Nils Caspar') }
    end
  end
end
