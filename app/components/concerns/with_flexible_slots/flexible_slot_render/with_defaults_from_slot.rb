module WithFlexibleSlots::FlexibleSlotRender::WithDefaultsFromSlot
  extend ActiveSupport::Concern

  included do 
    option :slot
    delegate :component, :tag, :options, to: :slot, prefix: :default
    delegate :merge_attributes, to: :helpers

    def tag
      @tag_value ||= super || default_tag
    end
    
    def component
      @component_value ||= super || default_component
    end

    def options
      @options_value ||= merge_attributes(super, default_options)
    end
  end
end
