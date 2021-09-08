module WithFlexibleSlots::FlexibleSlotRender::WithConfigurationFromOwner

  include WithFlexibleSlots::FlexibleSlotRender::WithOwnerAttributesForSlot

  delegate :slot_name, to: :configuration
  delegate :tag, :component, :params, :options, to: :@configuration_from_owner, prefix: :settings, allow_nil: true

  def call
    with_configuration_from_owner do
      super
    end
  end

  def tag
    super || settings_tag
  end

  def component
    super || settings_component
  end

  def params
    super || settings_params
  end

  def options
    merge_attributes(settings_options, super)
  end

  def with_configuration_from_owner(&block)
    # Read the configuration only once and cache it for the time of the render
    # in case the owner does some heavy computations there
    @configuration_from_owner = ConfigurationFromOwner.new(owner_attribute_for_slot(:settings))
    begin
      block.call
    ensure
      # But clear it after render in case the slot gets rendered multiple times
      # 
      @configuration_from_owner = nil
    end
  end

  class ConfigurationFromOwner
    extend Dry::Initializer
    with_options optional: true do
      option :options
      option :tag
      option :component
      option :params
    end
  end

end
