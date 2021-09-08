class WithFlexibleSlots::FlexibleSlot
  extend Dry::Initializer
  option :slot_name
  option :component, optional: true
  option :tag, optional: true
  option :render_class, optional: true
  rest_options :options

  def call(slot_owner, *args, **options, &block)
    render_class.new(*args, slot_owner: slot_owner, slot: self, **options).call(&block)
  end

  def render_class
    super || WithFlexibleSlots::FlexibleSlotRender
  end
end
