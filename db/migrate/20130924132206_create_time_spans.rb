class CreateTimeSpans < ActiveRecord::Migration
  def change
    create_table :time_spans do |t|
      t.date :date
      t.integer :duration
      t.integer :duration_days
      t.integer :duration_bonus
      t.references :user
      t.references :time_type
      t.references :time_spanable, polymorphic: true, index: true

      t.timestamps
    end
    add_index :time_spans, :user_id
    add_index :time_spans, :time_type_id
    add_index :time_spans, :time_spanable_id
  end
end
