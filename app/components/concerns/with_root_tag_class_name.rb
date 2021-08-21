module WithRootTagClassName
  extend ActiveSupport::Concern

  included do
    define_method :root_tag_attributes do |*extra_attributes_list, **extra_attributes|
      extra_attributes_list << {class: class_name}
      super(*extra_attributes_list, **extra_attributes)
    end
  end
end
