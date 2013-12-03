# Class for synchronizing Nine Customers
class CustomerSync
  def sync
    sync_all_customers
  end

  private

  def remote_customers
    @remote_customers ||= CustomerPlugin::Customer.all.to_a
  end

  def remote_customer_ids
    @remote_customer_ids ||= @remote_customers.collect { |remote_customer| remote_customer.id }
  end

  def remote_customer_logins
    @remote_customer_logins ||= CustomerPlugin::CustomerLogin.all.to_a
  end

  def sync_all_customers
    remote_customers.each { |remote_customer| sync_customer(remote_customer) }
    remove_deleted_customers
    true
  end

  def sync_customer(remote_customer)
    local_customer = Customer.find_or_create_by_number(remote_customer.id)

    sync_customer_attributes(local_customer, remote_customer)
  end

  def remove_deleted_customers
    ::Customer.all.each do |local_customer|
      local_customer.destroy unless remote_customer_ids.index(local_customer.number)
    end
  end

  def sync_customer_attributes(local_customer, remote_customer)
    local_customer.number = remote_customer.id
    local_customer.name = "#{remote_customer.firstname} #{remote_customer.companyname}".strip
    local_customer.abbreviation = find_customers_abbreviation(remote_customer)
    local_customer.save!
  end

  def find_customers_abbreviation(remote_customer)
    remote_customer_login = find_remote_customer_login(remote_customer)
    remote_customer_login ? remote_customer_login.login : nil
  end

  def find_remote_customer_login(remote_customer)
    remote_customer_logins.find { |remote_customer_login| remote_customer_login.id == remote_customer.id }
  end
end
