module WithFlexibleSlots::FlexibleSlotRender::WithDefaultsFromOwner
  extend ActiveSupport::Concern

  delegate :slot_name, to: :configuration
  delegate :merge_attributes, to: :helpers

  # No caching in case owner gets rendered multiple times
  # and value for the attribute changes
  def tag
    super || owner_attribute_for(slot_name, :tag)
  end

  def component
    super || owner_attribute_for(slot_name, :component)
  end

  def params
    super || owner_attribute_for(slot_name, :params)
  end

  def options
    merge_attributes(owner_attribute_for(slot_name, :options), super)
  end

  def owner_attribute_for(name = slot_name, suffix = nil)
    method_name = method_name_for(name, suffix)
    slot_owner.send(method_name) if slot_owner.respond_to?(method_name.to_sym)
  end

  def method_name_for(name = slot_name, suffix = nil)
    "#{slot_name.to_s.singularize}_slot_#{suffix}".to_sym
  end
end
