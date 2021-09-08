# frozen_string_literal: true

class FlexibleComponent < ViewComponent::Base
  include WithFlexibleSlots

  flexibly_renders_many :slots, tag: :h1

  def slot_slot_options
    {
      style: 'background: lime'
    }
  end
end
