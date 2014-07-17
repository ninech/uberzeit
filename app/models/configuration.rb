class Configuration
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveModel::Dirty

  define_attribute_methods Setting::VALID_SETTING_KEYS

  validates :work_per_day_hours, numericality: { greater_than_or_equal_to: 0 }
  validates :vacation_per_year_days, format: { with: /\A\d+(?:.[05])?\z/ }

  define_model_callbacks :save

  after_save :flush_cache, if: -> { work_per_day_hours_changed? }

  Setting::VALID_SETTING_KEYS.each do |key|
    define_method(key) do
      instance_variable_get("@#{key}") || Setting.send(key)
    end

    define_method("#{key}=") do |value|
      send("#{key}_will_change!") unless "#{send(key)}" == "#{value}"
      instance_variable_set("@#{key}", value)
    end
  end

  def save
    return false unless valid?
    run_callbacks :save do
      Setting::VALID_SETTING_KEYS.each do |key|
        value = instance_variable_get("@#{key}")
        Setting.send("#{key}=", value) if send("#{key}_changed?")
      end
    end
  end

  def update_attributes(attributes)
    attributes.each do |key, value|
      method = "#{key}="
      send(method, value) if respond_to?(key)
    end
    save
  end

  def persisted?
    true
  end

  def to_key
    nil
  end

  private

  def flush_cache
    Day.delete_all
  end
end
