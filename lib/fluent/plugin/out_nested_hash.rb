require "fluent/plugin/output"
require "fluent/plugin/nested_hash_filter/nested_object"

module Fluent::Plugin
  class OutNestedHash < Output
    Fluent::Plugin.register_output("nested_hash", self)

    helpers :event_emitter

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

    def process tag, es
      es.each do |time, record|
        record = Fluent::NestedHashFilter::NestedObject.convert record, connector: @connector, jsonify_keys: @acts_as_json
        router.emit @tag_prefix + tag, time, record
      end
    end
  end
end
