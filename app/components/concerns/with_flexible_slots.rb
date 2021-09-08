module WithFlexibleSlots

  extend ActiveSupport::Concern

  class_methods do
    def flexible_slot(*args, render_class: FlexibleSlotRender, slot_class: FlexibleSlot, **options)
      # Slot only needs to be created once, with its defaults
      slot = slot_class.new(*args, render_class: render_class, **options)
      # But will be rendered multiple times
      -> (*args, **options, &block) do
        slot.call(self, *args, **options, &block)
      end
    end
  end
end
  
