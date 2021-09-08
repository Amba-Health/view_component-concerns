module WithFlexibleSlots

  extend ActiveSupport::Concern

  class_methods do
    def flexible_slot(slot_name = nil, *args, render_class: FlexibleSlotRender, slot_class: FlexibleSlot, **options)
      # Slot only needs to be created once, with its defaults
      slot = slot_class.new(*args, slot_name: slot_name, render_class: render_class, **options)
      # But will be rendered multiple times
      -> (*args, **options, &block) do
        slot.call(self, *args, **options, &block)
      end
    end
    
    def flexibly_renders_one(slot_name, *args, **options)
      renders_one slot_name, flexible_slot(slot_name, *args, **options)
    end

    def flexibly_renders_many(slot_name, *args, **options)
      renders_many slot_name, flexible_slot(slot_name, *args, **options)
    end
  end
end
  
