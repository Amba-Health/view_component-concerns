# frozen_string_literal: true

class HostComponent < ViewComponent::Base
  extend Dry::Initializer
  include WithRootTag
  include WithClassName
  include WithRootTagClassName

  rest_options :options

  renders_one :area, TagComponent
end
