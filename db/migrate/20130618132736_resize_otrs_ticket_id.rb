class ResizeOtrsTicketId < ActiveRecord::Migration
  def up
    change_column :activities, :otrs_ticket_id, :integer, limit: 8
  end

  def down
    change_column :activities, :otrs_ticket_id, :integer
  end
end
