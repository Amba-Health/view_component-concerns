module WithRenderedRootTag

  extend ActiveSupport::Concern

  included do
    define_method :call do
      root_tag
    end
  end
end
