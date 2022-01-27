View component concerns
===

> **Implementation of a few of those has been started (see `app/components/concerns`), but a lot more needs doing**

Support helpers
---

Before getting to components themsleves a couple of helpers are necessary to make future work easier

### Merging attributes

When building front-end components, it pays to not close down things too much when it comes to the attributes that'll end up on the tags. There's often need to add an extra class or set up a few extra data-attributes.

This requires to merge different sets of attributes, handling specific keys like `class` or `data.controller`/`data.action` (for Stimulus) slightly differently than a classic `deep_merge`.

That's the role of the `merge_attributes` helper, which will merge multiple set of attributes into one hash of attributes,
treating specified keys as DOM Token Lists so that their values combine rather than get overriden.

```rb
# Creates: {class: 'my-component parent_component__child',data: {action: 'stimulus-controller#action'}}
merge_attributes(
  {class: 'my-component'}, 
  {
    class: 'parent-component__child', 
    data: {action: 'stimulus-controller#action'}
  }
)
```

That helper opens the door to abstracting specific sets of components in their own helpers to provide specific vocabulary,
say for configuring specific Stimulus controllers

```rb
merge_attributes(
  {class: 'my-component'},
  dialog_trigger(dialog_id: 'my-dialog') # Returns the right Stimulus controller/actions/targets/values
)
```

> Recommended merging order: attributes defined at component render win over attributes set in component templates which win over attributes computed at instanciation. This allows a couple of things:
>
> - Allowing caller of component to set the value it requires
> - Allowing to gather related CSS classes in the template or `call` method instead of having some in the template/`call` and others in the component  

TODO: Allow any of the arguments to be an array of attribute hashes and flatten the hash. This would allow to make the merge as late as possible while components/helpers gather lists of attributes to merge. This may require to provide a `flatten_depth` option to the method.

### TBD: Storing data against the request

Because components each have their own scope when accessing instance variables, helpers can no longer rely on them for tracking some per-request state. An example of this would be a list of SVG icons to be appended as a sprite (but only once).

`content_for` is not suitable as it serialises any data passed to it as a String, preventing the use of of more complex structures like arrays, hashes or other kinds of non String data.

`request.flash` risks leaking to the next request if not cleaned up when the request ends.

TODO: Find another mechanism to provide a `get`/`set`/`has` feature for storing data against the request.

Components concerns
---

###  Declarative attributes

An idea taken from <https://github.com/palkan/view_component-contrib#hanging-initialize-out-to-dry>

Rails provides us with some stuff (thanks James & Nic) out of the box through `ActiveModel::Model` and `ActiveModel::Attributes`. With a little monkey patching, we can gather the unknown attributes and that's pretty close to having declarative attributes for components:

```rb
module WithUnknownAttributes
    
  def assign_unknown_attribute(attribute_name,value)
      unknown_attributes[attribute_name.to_sym] = value
  end

  def unknown_attributes
      @unknown_attributes ||= {}
  end

  private

  def _assign_attribute(k, v)
    setter = :"#{k}="
    if respond_to?(setter)
        public_send(setter, v)
    else
        assign_unknown_attribute(k,v)
    end
  end
    
end
```

Which we can then include and use as so:

```rb
class UnknownAttributesComponent < ViewComponent::Base
  include ActiveModel::Model
  include ActiveModel::Attributes
  include WithUnknownAttributes

  attribute :str, default: "Hello"
  attribute :obj, default: {}
end
```

See `UnknownAttributesComponent`

Only caveat is that the defaults are not computed at each initialisation (like for `dry-initializer`). For that use case, we can always declare our own attribute accessor, I guess.

`dry-initializer` unfortunately is still pending merge of [that PR for gathering rest attributes](https://github.com/dry-rb/dry-initializer/pull/89). Once that's done it may be worth a review to get default values computed at each initialization (or even better, at first read, no sense computing a default until accessed)

### Root

A good amount of components will render a single tag (with various kinds of content) or wrap a single component as a root. It makes sense to provide some vocabulary to make this behaviour explicit and extendable.

#### `WithRoot`

A `root` method renders that root tag wrapping the component's `content` or a custom block, with the required `root_tag_name` and `root_attributes`. It can be invoked:

- by inline components

  ```rb
  def call
    root('Some content for the root tag')
  end

  # Or

  def call
    root do
      "Some content for the root tag"
    end
  end
  ```

- and templated ones

  ```erb
    <%= root do %>
      Some content for the root_tag
    <% end %>
  ```

To help legibility of the tempalte the tag name and attributes
can be overriden when calling `root_tag`

```erb
<%# 
  Allows the component to enforce semantics at render 
  and set a related classes in the same place
%>
<%= root(:ul, class:'position-relative') %>
  <% children.each do |child| %>
    <li class="position-absolute">
      <%= child %>
    </li>
  <% end %>
<% end %>
```

> **Important** `WithRootTag` only provides the `root`, `root_attributes` and `root_tag_name` methods. It's up to the component to call them as necessary.
>
> It's likely you'll want the root_tag to wrap the render, however because view_component doesn't accept a component with both `call` and a template, the concern can not automagically register a `call` method.

### TODO?: `WithRootOptions`

`root_tag_name` and `root_attributes` are defined as `attr_reader`
Those should be providable at initialization
as `dry-initializer` options so that components can be initialized as such:

```rb
MyComponent.new(root_tag_name: :header, root_attributes: {}, class: 'test')
```

An alias of `root_tag_name` to `tag_name` would likely be handy, just as `root_attributes`.

Shorthands params to allow
`MyComponent.new(:header, :content)` would likely be welcome too, but probably best provided as a code sample to copy rather than baked in to let more complex components relying on `root` provide more relevant shorthands to their use.

Also, is there a way to have some DSL at class level for setting a default `root_tag_name` and `root_attributes`

```rb
class MyComponent < ViewComponent::Base
  root_tag_name :ul
  root_attributes: {
    class: 'some-class'
  }

  def root_tag_name
    if ordered?
      :ol
    else
      super
    end
  end
end
```

### `WithRenderedRootTag`

Defines a `call` method that renders the `root`.

This allows to define a `TagComponent` as such:

```rb
class TagComponent < ViewComponent::Base
  include WithRoot
  include WithRenderedRoot
end
```

It can later on be used for components that require slots where tag names or attributes can be configured, a classic example being headings:

```rb
class UserInfoComponent < ViewComponent::Base
  renders_one name, -> (tag_name=:h2,*args, **options) {
    TagComponent(tag_name,*args, **options)
  }
end

render UserInfoComponent.new do |user_info|
  user_info.name :h3, @user.full_name, data: {'toc-target': 'entry'}
end
```

#### TODO: `WithWrappingRoot`

For components rendering a single root element, we can offer to wrap the render within the `root` so that the component can focus on rendering the content of that root tag.

```rb
class SingleElementComponent < ViewComponent::Base
  include WithRootTag
  include WithWrappingRootTag

  root_tag_name :header

  def call
    # Focuses on rendering the content of the header
  end
end
```

### Managing attributes

There are a few places where attributes can be passed to a component:

1. Outside the component, at instanciation: when the component is instanciated pass attributes to it

  ```erb
  <%= render MyComponent.new(class: 'some class') %>
  ```

2. Outside the component, within content: helps use the component's API to build attributes values. IDs are a good candidate for example

   ```erb
   <%= render MyComponent.new do |component| %>
    <% component.attributes(class: component.dom_class('--modifier')) %>
   <% end %>
   ```

3. Inside the component, when rendering the `root_tag`: This helps compute attributes based on the components's options

  ```rb
  def root(&block)
    tag.send(root_tag_name, root_tag_attributes, &block)
  end

  def root_attributes
    {class: 'some-class'}
  end
  ```

  This can be divided in different methods, for ex:

  ```
  def collapsible_attributes
    {'aria-expanded': true}
  end
  def root_attributes
    helpers.merge_attributes({class: 'some-class'},collapsible_attributes)
  end
  ```

4. Inside the component, when rendering the root_tag, allowing to keep related attributes (class names, IDs and `for`/`aria-XXX`/...) in the same file

  ```erb
  <%= root(class: 'my-component') do %>
    <h2 class="my-component__heading"></h2>
  <% end %>
  ```

A sensible order for merging would be (left most winning): Content time attributes, instanciation attributes, template/`call` attributes, `root_attributes`.

###  Identifiers

Help provide component specific identifiers, that can be used for IDs, CSS classes or hooking Stimulus controllers, in the spirit of <https://github.com/palkan/view_component-contrib#using-with-stimulusjs>

#### `indentifier` and `instance_identifier`

`identifier` derives an identifier from the component's class name (unless overriden). `instance_identifier` derives an identifier specific to that component's instance, helpful if the component is repeated within a page

Both allow to specific a separator used to replace the `::` coming from namespacing components. This'll help generate:

- IDs using `.`, which will reduce the likelyhood of them being used for styling as it requires the extra effort of escaping the `.`
- class names using `_` (or `-`, though it could lead to some colisions), leaving `__` and `--` to respect the `BEM` convention
- stimulus controllers using `--`

#### `dom_id`

Similar to what `dom_id` does for a model, generate an instance specific ID

#### `dom_class`

Similar to what `dom_class` does for a model, generates an instance specific ID. Allows to prefix the classes with a custom namespace to avoid colisions

### `bem_element`, `bem_modifier`, `bem_element_modifier`, `bem_modifier_element` (unless `bem(element: 'a', modifier: 'b')`)

Uses `dom_class` to help generate BEM class names. This could be leveraged to automatically attach classes to slots. Likely supported by out of component helpers.

###  `stimulus_attributes`

Automatically attaches the Stimulus controller corresponding to that component.

May rely on a `stimulus_attributes` helper that more generally helps create attributes for a component (API to be defined):

```rb
stimulus_attributes('dialog ', {target: ???, value: ???, action: ???})
```

###  Components rendering specific models

Some component's role is to render data coming from a model.
This could be standardized through an `object` attribute (with accessors) for the component,
with the ability to:

- set it after initialization
- have it modify the identifiers:
  - append the `dom_id` of the model to the component's `dom_id` (possibly with an escape hatch)
  - append the `dom_class` of the model to the component's `dom_class` (possibly with an escape hatch)
  - ? pass the model ID (or data) to a specific Stimulus or data attribute for the Stimulus controller

### Slots

To be expanded, but on the top of my head:

- getting the `proc` to call an instance method, which will allow for possibly overriding the method: `SINGULAR_SLOT_NAME_slot`
- flexible slots with corresponding component methods: `SINGULAR_SLOT_NAME_slot_component`, `SINGULAR_SLOT_NAME_slot_params`,
`SINGULAR_SLOT_NAME_slot_options`,
`SINGULAR_SLOT_NAME_slot_block`

```rb
class ParentComponent < ViewComponent::Base
  include WithFlexibleSlot

  flexibly_renders_many :slots, component: SomeComponent
end
```

```erb
<%= render ParentComponent do |component| %>
  <%# Just provides the "content" %>
  <% component.slot "Content" %>
  <%# Pretty similar as before %>
  <% component.slot {"Content"} %>
  <%# Renders a `TagComponent` %>
  <% component.slot tag: :ul, class: '' %>
  <%# Overrides component defined for the slot and passes it the given attributes %>
  <% component.slot component: OtherComponent, **attributes %>
  <%# TODO: Pass a fully configured component %>
  <%# This'll likely require the component to respond to a method for setting extra options when used as a slot %>
  <%# component.slot OtherComponent.new(attributes) %>
<% end %>
```

### Slot reuse

Some components may need to iterate over both a `collection`, but also a `slots` for each items of the collection. For example a `DataTable` component
letting you define `slots` for each of the columns, but also providing helpers
for iterating over the columns (like computing heading/row ids...).

There are several routes possible:

- lifting of current caching mechanisms within `SlotV2`/`ViewComponent::Base` - using the [`Repeatable`](app/components/repeatable.rb) class as such:

    ```rb
    # in component
    renders_many :items, -> (*args, **kwargs, &block) {
      ComponentTemplate.new(TagComponent, *args, **kwargs, &block)
    }
    ```

    ```erb
    <% records.each do |record| %>
      <%= items.each do |item| %>
        <% item.render_within(self, record: record) %>
      <% end %>
    ```

- cloning slots?

### Wrapping

Pushing the idea of Wrapped components from `view_component-contrib`, a `WithWrapper` concern would provide:

- a `wrapper_tag_name` option to set the tag name for the wrapper
- a `wrapper_attributes` option to set attributes for the wrapper
- a `wrapper_component` option to set a component
- a `wrapped` boolean option to tell whether the component should automatically render wrapped or not
- a `wrapper` `attr_reader` for getting the instance of the wrapper for after initialization configuration
- a `render_wrapper` method to let an outside component render the wrapper

By the looks of it, the `wrapper` is kind of a flexible slot so it may be the way to go.

### Delegation

Provide a way to create a component that delegates most of its behaviour to another one. This is useful for creating specialised behaviours of low level components, pre-filling some slots in a component:

```rb
class SpecialComponent < ViewComponent::Base
  include WithDelegate
  
  delegate_class BaseComponent

  def base_component_slot_name(*args, **args, &block)
    # Intercept slot calls to parent component
  end
end
```

The `WithDelegate` concern provides:

- a `delegate` method to lazily instanciate the delegate with the provided attributes, which will allow its rendering
- a `delegate_attributes` to pass the appropriate attributes to the delegate when instanciated (by default, all attributes)
- ~a `method_missing` implementation passing any calls to the delegate~ (Rails has `delegate_missing_to`)

```erb
<%= render delegate do |component| %>
  <%# Fill whichever slots need filling %>
<% end %>
```
