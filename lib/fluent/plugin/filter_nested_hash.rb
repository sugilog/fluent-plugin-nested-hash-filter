require "fluent/plugin/nested_hash_filter/nested_object"

module Fluent
  class FilterNestedHash < Filter
    Plugin.register_filter("filter_nested_hash", self)

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
