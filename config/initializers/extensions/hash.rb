class Hash
  # File activesupport/lib/active_support/core_ext/hash/keys.rb, line 130
  def deep_symbolize_keys
    deep_transform_keys{ |key| key.to_sym rescue key }
  end

  # File activesupport/lib/active_support/core_ext/hash/keys.rb, line 84
  def deep_transform_keys(&block)
    result = {}
    each do |key, value|
      result[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys(&block) : value
    end
    result
  end

  # File activesupport/lib/active_support/core_ext/hash/keys.rb, line 137
  def deep_symbolize_keys!
    deep_transform_keys!{ |key| key.to_sym rescue key }
  end

  # File activesupport/lib/active_support/core_ext/hash/keys.rb, line 95
  def deep_transform_keys!(&block)
    keys.each do |key|
      value = delete(key)
      self[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys!(&block) : value
    end
    self
  end
end
