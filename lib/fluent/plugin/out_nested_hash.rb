require "fluent/plugin/nested_hash_filter/nested_object"

module Fluent
  class OutNestedHash < Output
    Plugin.register_output("nested_hash_filter", self)

    def configure conf
      super
    end

    def start
      super
    end

    def shutdown
      super
    end

    def emit tag, es, chain
      es.each do |time, record|
        record = Fluent::NestedHashFilter::NestedObject.convert record
        Fluent::Engine.emit tag, time, record
      end

      chain.next
    end
  end
end
