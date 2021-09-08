# frozen_string_literal: true

class FlexibleComponent < ViewComponent::Base
  include WithFlexibleSlots

  renders_many :slots, flexible_slot(tag: :h1)
end
