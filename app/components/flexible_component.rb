# frozen_string_literal: true

class FlexibleComponent < ViewComponent::Base
  include WithFlexibleSlots

  renders_many :slots, flexible_slot(:slots, tag: :h1)

  def slot_slot_options
    {
      style: 'background: lime'
    }
  end
end
