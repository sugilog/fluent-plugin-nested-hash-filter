require "fluent/plugin/nested_hash_filter/version"
require "fluent/plugin/nested_hash_filter/nested_object"

module Fluent::Plugin
  class NestedHashFilter < Filter
    Plugin.register_filter('nested_hash_filter', self)

    config_param :tag_prefix, :string, :default => nil

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
      rewrite_tag tag
      NestedObject.convert record
    end

    def rewrite_tag tag
      if @tag_prefix
        tag.gsub! /^/, @tag_prefix
      end
    end
  end
end
