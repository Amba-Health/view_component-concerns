class WithFlexibleSlots::FlexibleSlotRender
  extend Dry::Initializer
  
  include Base
  include WithDefaultsFromOwner
  include WithConfigurationFromOwner
  include WithDefaultsFromConfiguration
end
