# frozen_string_literal: true

class FlexibleComponent < ViewComponent::Base
  include WithFlexibleSlots

  flexibly_renders_many :flexible_slots, tag: :h1

  def flexible_slot_slot_settings
    {
      options: {"class": "italic"}
    }
  end

  def flexible_slot_slot_options
    {
      style: 'background: lime'
    }
  end
end
