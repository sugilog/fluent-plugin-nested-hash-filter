require "fluent/plugin/nested_hash_filter/nested_object"

module Fluent
  class OutNestedHash < Output
    Plugin.register_output("nested_hash", self)

    config_param :tag_prefix, :string
    config_param :connector,  :string, :default => nil

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
        record = Fluent::NestedHashFilter::NestedObject.convert record, connector: @connector
        Fluent::Engine.emit @tag_prefix + tag, time, record
      end

      chain.next
    end
  end
end
