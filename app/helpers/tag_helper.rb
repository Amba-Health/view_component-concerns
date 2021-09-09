module TagHelper
  def merge_attributes(
      attributes, 
      *extra_attributes_list, 
      token_list_attributes: [[:class], [:data, :controller]],
      **extra_attributes
    )
    return if attributes.nil?

    # Ruby considers a final hash to be extra options
    # rather than an argument
    extra_attributes_list << extra_attributes

    # `Hash`es can have both string and symbol keys
    # to allow merging maps with different kinds of keys
    # we need to use a common type, symbol, picked arbitrarily
    result = attributes.deep_symbolize_keys
  
    return result if extra_attributes_list.empty?
    extra_attributes_list = extra_attributes_list
      .flatten # Handle nested arrays that may have been used for collecting series of attributes
      .reject{|item| item.blank?} # No need to process blank values
      .map(&:deep_symbolize_keys) # Ensure we don't duplicate keys
    
    extra_attributes_list.each_with_index do |extra_attributes, index|
      # deep_merge the attributes so we handle the data Hash properly
      result = result.deep_merge extra_attributes
    end 

    token_list_attributes.each do |attribute_path|
      value = token_list(attributes.dig(*attribute_path), *extra_attributes_list.map{|attr| attr.dig(*attribute_path)})
      bury(result, *attribute_path, value) unless value.blank?
    end

    result
  end

  private

  # Opposite of `Hash#dig` for deep setting hashes values
  # https://bugs.ruby-lang.org/issues/13179
  def bury(hash, *where, value)
      pp "burying", hash, where, value
      me=hash
      where[0..-2].each{|key|
        me=me[key] || {} # Create a new hash if the key is not found
      }
      me[where[-1]]=value
  end
end
