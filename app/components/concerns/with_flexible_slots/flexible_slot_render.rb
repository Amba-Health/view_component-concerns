class WithFlexibleSlots::FlexibleSlotRender
  extend Dry::Initializer

  rest_params :args
  option :slot_owner
  option :component, optional: true
  option :tag, optional: true
  option :content, optional: true
  rest_options :options

  include WithDefaultsFromSlot
  
  delegate :helpers, :capture, to: :slot_owner

  def call(&block)
    render_component || render_tag(block) ||  render_block(block) || render_content || nil
  end

  def render_tag(block)
    if tag.present?
      if content
        helpers.tag.send(tag, content, **options)
      else
        helpers.tag.send(tag, capture(&block), **options)
      end
    end
  end

  def render_component
    if component.present?
      # For components the block will be provided 
      # by the ViewComponent::SlotV2 when rendering
      component.new(*args, tag: tag, content: content, **options)
    end
  end

  def render_content
    return content if content
  end
  
  def render_block(block)
    return capture(&block) if block
  end
end
