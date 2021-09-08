module WithFlexibleSlots::FlexibleSlotRender::WithDefaultsFromConfiguration
  extend ActiveSupport::Concern

  included do 
    option :configuration
    delegate :component, :tag, :options, to: :configuration, prefix: :default
    delegate :merge_attributes, to: :helpers

    def tag
      super || default_tag
    end
    
    def component
      super || default_component
    end

    def options
      merge_attributes(default_options, super)
    end
  end
end
