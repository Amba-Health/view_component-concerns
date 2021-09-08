class WithFlexibleSlots::FlexibleSlotRender
  extend Dry::Initializer
  
  include Base, WithDefaultsFromOwner, WithDefaultsFromConfiguration
end
