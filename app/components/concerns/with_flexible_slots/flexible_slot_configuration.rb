class WithFlexibleSlots::FlexibleSlotConfiguration
  extend Dry::Initializer
  option :slot_name
  option :component, optional: true
  option :tag, optional: true
  option :render_class, optional: true

  rest_params :params
  rest_options :options

  def create_render(slot_owner, *params, **options, &block)
    render_class.new(*params, slot_owner: slot_owner, configuration: self, **options).call(&block)
  end

  def render_class
    super || WithFlexibleSlots::FlexibleSlotRender
  end
end
