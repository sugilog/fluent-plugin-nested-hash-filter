module Fluent
  module NestedHashFilter
    class NestedObject
      DEFAULT_CONNECTOR = "."

      def self.convert object, options = {}
        converter = new options
        converter.select object
        converter.output
      end

      attr_accessor :output, :output_keys
      attr_reader   :connector

      def initialize options = {}
        @output      = {}
        @output_keys = []
        @connector   = options[:connector] || DEFAULT_CONNECTOR
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

      def update value
        unless current_key.empty?
          @output.update current_key => value
        end
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
