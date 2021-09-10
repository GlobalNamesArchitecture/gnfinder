# frozen_string_literal: true

# Monkey patch for underscores.
class String
  def underscore
    gsub(/::/, '/')
      .gsub(/([a-z\d])([A-Z])/) do
      "#{Regexp.last_match(1)}_#{Regexp.last_match(2)}"
    end
      .downcase
  end
end

# Hash monkey patches from ActiveSupport
class Hash
  # Returns a new hash with all keys converted to strings.
  #
  #   hash = { name: 'Rob', age: '28' }
  #
  #   hash.stringify_keys
  #   # => {"name"=>"Rob", "age"=>"28"}
  def stringify_keys
    transform_keys(&:to_s)
  end

  # Destructively converts all keys to strings. Same as
  # +stringify_keys+, but modifies +self+.
  def stringify_keys!
    transform_keys!(&:to_s)
  end

  # Returns a new hash with all keys converted to symbols, as long as
  # they respond to +to_sym+.
  #
  #   hash = { 'name' => 'Rob', 'age' => '28' }
  #
  #   hash.symbolize_keys
  #   # => {:name=>"Rob", :age=>"28"}
  def symbolize_keys
    transform_keys do |key|
      key.to_sym
    rescue StandardError
      key
    end
  end
  alias to_options symbolize_keys

  # Destructively converts all keys to symbols, as long as they respond
  # to +to_sym+. Same as +symbolize_keys+, but modifies +self+.
  def symbolize_keys!
    transform_keys! do |key|
      key.to_sym
    rescue StandardError
      key
    end
  end
  alias to_options! symbolize_keys!

  # Validates all keys in a hash match <tt>*valid_keys</tt>, raising
  # +ArgumentError+ on a mismatch.
  #
  # Note that keys are treated differently than HashWithIndifferentAccess,
  # meaning that string and symbol keys will not match.
  def assert_valid_keys(*valid_keys)
    valid_keys.flatten!
    each_key do |k|
      unless valid_keys.include?(k)
        raise ArgumentError, "Unknown key: #{k.inspect}. Valid keys are: #{valid_keys.map(&:inspect).join(', ')}"
      end
    end
  end

  # Returns a new hash with all keys converted by the block operation.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  #
  #  hash = { person: { name: 'Rob', age: '28' } }
  #
  #  hash.deep_transform_keys{ |key| key.to_s.upcase }
  #  # => {"PERSON"=>{"NAME"=>"Rob", "AGE"=>"28"}}
  def deep_transform_keys(&block)
    _deep_transform_keys_in_object(self, &block)
  end

  # Destructively converts all keys by using the block operation.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_transform_keys!(&block)
    _deep_transform_keys_in_object!(self, &block)
  end

  # Returns a new hash with all keys converted to strings.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  #
  #   hash = { person: { name: 'Rob', age: '28' } }
  #
  #   hash.deep_stringify_keys
  #   # => {"person"=>{"name"=>"Rob", "age"=>"28"}}
  def deep_stringify_keys
    deep_transform_keys(&:to_s)
  end

  # Destructively converts all keys to strings.
  # This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_stringify_keys!
    deep_transform_keys!(&:to_s)
  end

  # Returns a new hash with all keys converted to symbols, as long as
  # they respond to +to_sym+. This includes the keys from the root hash
  # and from all nested hashes and arrays.
  #
  #   hash = { 'person' => { 'name' => 'Rob', 'age' => '28' } }
  #
  #   hash.deep_symbolize_keys
  #   # => {:person=>{:name=>"Rob", :age=>"28"}}
  def deep_symbolize_keys
    deep_transform_keys do |key|
      key.to_sym
    rescue StandardError
      key
    end
  end

  # Destructively converts all keys to symbols, as long as they respond
  # to +to_sym+. This includes the keys from the root hash and from all
  # nested hashes and arrays.
  def deep_symbolize_keys!
    deep_transform_keys! do |key|
      key.to_sym
    rescue StandardError
      key
    end
  end

  private

  # Support methods for deep transforming nested hashes and arrays.
  def _deep_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.each_with_object(self.class.new) do |(key, value), result|
        result[yield(key)] = _deep_transform_keys_in_object(value, &block)
      end
    when Array
      object.map { |e| _deep_transform_keys_in_object(e, &block) }
    else
      object
    end
  end

  # rubocop:disable all
  def _deep_transform_keys_in_object!(object, &block)
    case object
    when Hash
      object.each_key do |key|
        value = object.delete(key)
        object[yield(key)] = _deep_transform_keys_in_object!(value, &block)
      end
      object
    when Array
      object.map! { |e| _deep_transform_keys_in_object!(e, &block) }
    else
      object
    end
  end
  # rubocop:enable all
end
