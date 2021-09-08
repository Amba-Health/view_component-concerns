module WithFlexibleSlots::FlexibleSlotRender::WithDefaultsFromSlot
  extend ActiveSupport::Concern

  included do 
    option :slot
    delegate :component, :tag, :options, to: :slot, prefix: :default
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
