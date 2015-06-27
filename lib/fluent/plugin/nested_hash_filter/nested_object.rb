module Fluent::Plugin::NestedHashFilter
  module NestedObject
    CONNECTOR = "."

    def self.convert object
      @output = {}
      @output_keys = []

      select object

      @output
    end

    def self.select object
      case object
      when Hash
        convert_hash object
      when Array
        convert_array object
      else
        update object
      end
    end

    def self.add_key key
      @output_keys.push key
    end

    def self.pop_key
      @output_keys.pop
    end

    def self.current_key
      @output_keys.join CONNECTOR
    end

    def self.update value
      unless current_key.empty?
        @output.update current_key => value
      end
    end

    def self.convert_hash hash
      if hash.keys.empty?
        update nil
      end

      hash.each do |key, value|
        add_key key
        select  value
        pop_key
      end
    end

    def self.convert_array array
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
