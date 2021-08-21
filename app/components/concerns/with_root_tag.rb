module WithRootTag

  extend ActiveSupport::Concern

  included do
    option :root_tag_attributes, optional: true
    option :root_tag_name, optional: true, default: proc {:div}
  end

  def root_tag(*args, **attributes_at_render, &block)
    tag_attributes = root_tag_attributes(attributes_at_render) || {}
    if block_given?
      tag.send(root_tag_name || tag_attributes[:tag_name], *args, **tag_attributes.without(:tag_name), &block)
    else
      tag.send(root_tag_name || tag_attributes[:tag_name], content, *args, **tag_attributes.without(:tag_name), &block)
    end
  end

  def root_tag_attributes(*extra_attributes_list, **extra_attributes)
    return super() if extra_attributes_list.empty? && extra_attributes.empty?
    helpers.merge_attributes(super(), *extra_attributes_list, **extra_attributes)
  end
end
