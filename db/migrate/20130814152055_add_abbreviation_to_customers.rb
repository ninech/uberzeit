class AddAbbreviationToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :abbreviation, :string
  end
end
