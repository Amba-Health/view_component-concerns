class ComponentTemplate < ViewComponent::Base

  def initialize(component_class, parent_component, *args, **attributes, &block)
    @parent_component = parent_component
    @component_class = component_class
    @attributes = attributes
    @block = block
  end

  def render_with(**attributes)
    @parent_component.render(@component_class.new(merge_attributes(attributes, @attributes)), &@block)
  end

  def merge_attributes(*attributes_list, **attributes)
    @parent_component.helpers.merge_attributes(*attributes_list, **attributes)
  end

  def call
    raise "ComponentTemplate is meant to be used through `#render_with`"
  end
end
