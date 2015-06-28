require "fluent/plugin/nested_hash_filter/nested_object"

module Fluent
  class FilterNestedHash < Filter
    Plugin.register_filter("nested_hash_filter", self)

    def configure conf
      super
    end

    def start
      super
    end

    def shutdown
      super
    end

    def filter tag, time, record
      Fluent::NestedHashFilter::NestedObject.convert record
    end
  end
end
