module WithFlexibleSlots::FlexibleSlotRender::WithOwnerAttributesForSlot

  def slot_name; end

  def owner_attribute_for_slot(suffix = nil, name: slot_name)
    method_name = method_name_for_slot(suffix, name: name)
    slot_owner.send(method_name) if slot_owner.respond_to?(method_name.to_sym)
  end

  def method_name_for_slot(suffix = nil, name: slot_name)
    return "#{name.to_s.singularize}_slot" if suffix.blank?

    "#{name.to_s.singularize}_slot_#{suffix}".to_sym
  end
end
