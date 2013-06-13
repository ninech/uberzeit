require 'spec_helper'

describe CustomerSync do
  let(:customer1) { OpenStruct.new id: 1, companyname: 'Yolo Inc.' }
  let(:customer2) { OpenStruct.new id: 2, companyname: 'Nils Vacuum Cleaners Inc.'}
  let(:customers) { [customer1, customer2] }

  def sync_customers
    CustomerSync.new.sync
  end

  before do
    CustomerPlugin::Customer.stub(:all) { customers }
  end

  it 'creates a local customer for every remote customer' do
    expect { sync_customers }.to change(Customer, :count).from(0).to(2)
  end

  it 'does not create local customers when they are already synced' do
    sync_customers
    expect { sync_customers }.to_not change(Customer, :count)
  end

  it 'deletes a local customer when the corresponding remote customer was deleted' do
    sync_customers

    customers.delete(customer2)
    expect { sync_customers }.to change(Customer, :count).from(2).to(1)
    expect { Customer.find(customer2.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe 'attributes' do
    before do
      sync_customers
    end
    subject { Customer.find(customer1.id) }
    its(:name) { should eq(customer1.companyname) }
  end
end
