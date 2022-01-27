module WithUnknownAttributes
    
    def assign_unknown_attribute(attribute_name,value)
        unknown_attributes[attribute_name.to_sym] = value
    end

    def unknown_attributes
        @unknown_attributes ||= {}
    end

    private
  
    def _assign_attribute(k, v)
      setter = :"#{k}="
      if respond_to?(setter)
          public_send(setter, v)
      else
          assign_unknown_attribute(k,v)
      end
    end
    
end