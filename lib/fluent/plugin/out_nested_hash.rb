require "fluent/plugin/nested_hash_filter/nested_object"

module Fluent
  class OutNestedHash < Output
    Plugin.register_output("nested_hash", self)

    config_param :tag_prefix, :string
    config_param :connector,  :string, :default => nil
    config_param :acts_as_json, :array, :default => []

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
        record = Fluent::NestedHashFilter::NestedObject.convert record, connector: @connector, jsonify_keys: @acts_as_json
        Fluent::Engine.emit @tag_prefix + tag, time, record
      end

      chain.next
    end
  end
end
