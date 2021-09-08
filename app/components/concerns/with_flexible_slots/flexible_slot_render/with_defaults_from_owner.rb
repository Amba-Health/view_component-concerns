module WithFlexibleSlots::FlexibleSlotRender::WithDefaultsFromOwner
  extend ActiveSupport::Concern
  include WithFlexibleSlots::FlexibleSlotRender::WithOwnerAttributesForSlot

  delegate :slot_name, to: :configuration
  delegate :merge_attributes, to: :helpers

  # No caching in case owner gets rendered multiple times
  # and value for the attribute changes
  def tag
    super || owner_attribute_for_slot(:tag)
  end

  def component
    super || owner_attribute_for_slot(:component)
  end

  def params
    super || owner_attribute_for_slot(:params)
  end

  def options
    merge_attributes(owner_attribute_for_slot(:options), super)
  end
end
