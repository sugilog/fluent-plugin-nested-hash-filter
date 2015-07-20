require 'json'

module Fluent
  module NestedHashFilter
    class NestedObject
      DEFAULT_CONNECTOR = "."

      def self.convert object, options = {}
        converter = new options
        converter.select object
        converter.output
      end

      attr_accessor :output, :output_keys, :jsonify_keys
      attr_reader   :connector

      def initialize options = {}
        @output       = {}
        @output_keys  = []
        @connector    = options[:connector] || DEFAULT_CONNECTOR
        @jsonify_keys = init_jsonify_keys options[:jsonify_keys]
      end

      def select object
        case object
        when Hash
          convert_hash object
        when Array
          convert_array object
        else
          update object
        end
      end

      def add_key key
        @output_keys.push key
      end

      def pop_key
        @output_keys.pop
      end

      def current_key
        @output_keys.join connector
      end

      def acts_as_json value
        json = JSON.parse value
        select json
      rescue TypeError => error
        err = JSON::ParserError.new error.message
        err.set_backtrace err.backtrace
        raise err
      rescue JSON::ParserError => error
        raise error
      ensure
        jsonified!
      end

      def jsonify_key?
        !!@jsonify_keys[current_key]
      end

      def jsonified!
        @jsonify_keys[current_key] = false
      end

      def init_jsonify_keys keys
        keys = keys || []
        values = [true] * keys.size
        zipped = keys.zip values
        Hash[ zipped ]
      end

      def update value
        case
        when current_key.empty?
          return
        when jsonify_key?
          acts_as_json value
        else
          @output.update current_key => value
        end
      rescue JSON::ParserError
        @output.update current_key => value
      end

      def convert_hash hash
        if hash.keys.empty?
          update nil
        end

        hash.each do |key, value|
          add_key key
          select  value
          pop_key
        end
      end

      def convert_array array
        if array.empty?
          update nil
        end

        array.each_with_index do |value, index|
          add_key index
          select  value
          pop_key
        end
      end
    end
  end
end
