# Class for synchronizing Nine Customers
class CustomerSync
  def sync
    sync_all_customers
  end

  private

  def remote_customers
    @remote_customers ||= CustomerPlugin::Customer.all
  end

  def remote_customer_ids
    @remote_customer_ids ||= @remote_customers.collect { |remote_customer| remote_customer.id }
  end

  def sync_all_customers
    remote_customers.each { |remote_customer| sync_customer(remote_customer) }
    remove_deleted_customers
    true
  end

  def sync_customer(remote_customer)
    local_customer = Customer.find_or_create_by_id(remote_customer.id)

    sync_customer_attributes(local_customer, remote_customer)
  end

  def remove_deleted_customers
    ::Customer.all.each do |local_customer|
      local_customer.destroy unless remote_customer_ids.index(local_customer.id)
    end
  end

  def sync_customer_attributes(local_customer, remote_customer)
    local_customer.name = "#{remote_customer.firstname} #{remote_customer.companyname}".strip
    begin
      local_customer.abbreviation = CustomerPlugin::CustomerLogin.find(remote_customer.id).login
    rescue => error
      Rails.logger.error "Error #{error.inspect} when syncing Customer ##{remote_customer.id} #{local_customer.name}"
    end
    local_customer.save!
  end
end
