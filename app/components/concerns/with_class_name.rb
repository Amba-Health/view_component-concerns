module WithClassName
  extend ActiveSupport::Concern

  # Allow configurable namespace_separator
  # so that:
  # IDs can use `.` (https://www.w3.org/TR/html401/types.html#type-name)
  # Classes can use `-` (little risk of collision there, between Navigation::Item and NavigationItem, but dashes are meaningful for conventions like BEM)
  # Stimulus cans use `--`
  def identifier(namespace_separator: '.')
    # Drop the last instance of 'Component'
    # https://stackoverflow.com/a/59597812
    @identifier ||= self.class.name.sub(/.*\KComponent/,'').downcase.dasherize.gsub('::',namespace_separator)
  end

  CLASS_PREFIX = "custom-"

  def class_name(suffix: '')
    CLASS_PREFIX + identifier(namespace_separator: '-') + suffix
  end

  def bem_block(name = nil, root: class_name)
    return root unless name
    return "#{root}-#{name.downcase.dasherize}" 
  end

  def bem_element(name, root: class_name)
    return "#{root}__#{name.downcase.dasherize}"
  end

  def bem_modifier(name, root: class_name)
    return "#{root}--#{name.downcase.dasherize}"
  end
end
