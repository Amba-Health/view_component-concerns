class UnknownAttributesComponent < ViewComponent::Base
    include ActiveModel::Model
    include WithUnknownAttributes
    include ActiveModel::Attributes
    
    attribute :str, default: "Hello"
    attribute :obj, default: {}

    # This could likely be configured through a custom DSL
    # attribute :custom {"Default value"} in case we need a per-instance value
    attribute :custom

    # Create our own accessor when needing custom default
    def custom
        super || default_custom
    end

    def default_custom
        "Custom string"
    end

    # attributes doesn't seem to use the `attr_reader`
    # we'd likely want to dirty check and cache there
    def attributes
        super.map do |k,v|
            [k, send(k)]
        end.to_h
    end

    def call
        "#{self.class.name} #{attributes.inspect} #{unknown_attributes.inspect}"
    end
end