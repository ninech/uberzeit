class CreateSettings < ActiveRecord::Migration
  def up
    create_table :settings do |t|
      t.string :key
      t.string :value

      t.timestamps
    end

    config_path = File.join(Rails.root, 'config', 'uberzeit.yml')
    yaml_config = YAML.load_file(config_path).fetch(Rails.env, {}).deep_symbolize_keys

    Setting.work_per_day_hours = yaml_config[:work_per_day_hours] || 8.5
    Setting.vacation_per_year_days = yaml_config[:vacation_per_year_days] || 25
  end

  def down
    drop_table :settings
  end
end
