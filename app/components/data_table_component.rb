# frozen_string_literal: true

class DataTableComponent < ViewComponent::Base
  extend Dry::Initializer
  option :data

  renders_many :columns, proc { |*args, **kwargs|
    ColumnComponent.new(*args, **kwargs, parent: self)
  }

  class ColumnComponent < ViewComponent::Base

    extend Dry::Initializer

    renders_one :heading, proc { |*args, **kwargs|
      HeadingComponent.new(*args, **kwargs, parent: self)
    }
    renders_one :cell, proc { |*args, **kwargs|
      CellComponent.new(*args, **kwargs, parent: self)
    }
    
    param :attribute
    option :parent
    
    attr_accessor :data
    attr_accessor :as

    def initialize(*args, **kwargs)
      @as = :heading
      super
    end

    # Create a cell and heading if they haven't been created
    # in the content already. Passes `nil` as otherwise
    # it'd call the getter for the slot
    def before_render
      cell(nil) unless cell
      heading(nil) unless heading
    end

    def value
      data[attribute]
    end

    def call
      send(as)
    end

    class CellComponent < TagComponent
      extend Dry::Initializer

      option :parent
      delegate :value, to: :parent
      
      def content
        value
      end
    end

    class HeadingComponent < TagComponent

      extend Dry::Initializer

      option :parent
      delegate :attribute, to: :parent

      def content
        attribute.to_s.humanize
      end
    end
  end
end
