# frozen_string_literal: true

class TagComponent < ViewComponent::Base
  extend Dry::Initializer
  include WithRootTag
  include WithClassName
  include WithRenderedRootTag
end
