class ListComponent < ViewComponent::Base
  renders_many :items, -> (*args, **kwargs, &block) {
    ComponentTemplate.new(TagComponent, self, *args, **kwargs, &block)
  }
end
