class AddCustomerNumber < ActiveRecord::Migration
  def up
    rename_column :customers, :id, :number
    add_column :customers, :id, :primary_key
    fix_customer_references(Project, :number, :id)
    fix_customer_references(Activity, :number, :id)
  end

  def down
    fix_customer_references(Project, :id, :number)
    fix_customer_references(Activity, :id, :number)
    remove_column :customers, :id
    rename_column :customers, :number, :id
  end

  private
  def fix_customer_references(model, source_id_name, target_id_name)
    model.all.each do |item|
      next if item.customer_id.nil?
      customer = Customer.where(source_id_name => item.customer_id).last
      item.customer_id = customer.send(target_id_name)
      item.save!(validate: false)
    end
  end
end
