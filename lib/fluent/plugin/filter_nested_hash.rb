require "fluent/plugin/nested_hash_filter/nested_object"

module Fluent
  class FilterNestedHash < Filter
    Plugin.register_filter("nested_hash", self)

    config_param :connector, :string, :default => nil

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
      Fluent::NestedHashFilter::NestedObject.convert record, connector: @connector
    end
  end
end
