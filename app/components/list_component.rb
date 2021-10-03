class ListComponent < ViewComponent::Base
  renders_many :items, -> (*args, **kwargs, &block) {
    ComponentTemplate.new(TagComponent, *args, **kwargs, &block)
  }
end
