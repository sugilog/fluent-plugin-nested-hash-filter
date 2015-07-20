require "test_helper"
require "fluent/plugin/nested_hash_filter/nested_object"

class NestedObjectTest < Test::Unit::TestCase
  setup do
    @instance = klass.new
  end

  sub_test_case "constants" do
    test "::DEFAULT_CONNECTOR" do
      assert_equal ".", klass::DEFAULT_CONNECTOR
    end
  end

  sub_test_case "convert" do
    test "convert by multi time" do
      hash = {"a" => 1, "b" => {"c" => 2, "d" => 3}, "e" => [4, 5], "f" => {}, "g" => []}
      output = klass.convert hash
      assert_equal Set["a", "b.c", "b.d", "e.0", "e.1", "f", "g"], output.keys.to_set
      assert_equal 1,   output["a"]
      assert_equal 2,   output["b.c"]
      assert_equal 3,   output["b.d"]
      assert_equal 4,   output["e.0"]
      assert_equal 5,   output["e.1"]
      assert_equal nil, output["f"]
      assert_equal nil, output["g"]

      hash = {"a" => {"b" => {"c" => 1, "d" => 2}, "e" => [3, 4]}}
      output = klass.convert hash
      assert_equal Set["a.b.c", "a.b.d", "a.e.0", "a.e.1"], output.keys.to_set
      assert_equal 1, output["a.b.c"]
      assert_equal 2, output["a.b.d"]
      assert_equal 3, output["a.e.0"]
      assert_equal 4, output["a.e.1"]
    end
  end

  sub_test_case "initialize" do
    test "without options" do
      assert_equal Hash.new, @instance.output 
      assert_equal Array.new, @instance.output_keys
      assert_equal ".", @instance.connector
      assert_equal Hash.new, @instance.jsonify_keys
    end

    test "with connector option" do
      @instance = klass.new connector: "-"
      assert_equal Hash.new, @instance.output 
      assert_equal Array.new, @instance.output_keys
      assert_equal "-", @instance.connector
      assert_equal Hash.new, @instance.jsonify_keys
    end

    test "with jsonify_keys option" do
      @instance = klass.new jsonify_keys: ["hoge.1", "fuga"]
      assert_equal Hash.new, @instance.output 
      assert_equal Array.new, @instance.output_keys
      assert_equal ".", @instance.connector
      assert_equal ["fuga", "hoge.1"], @instance.jsonify_keys.keys.sort
      assert @instance.jsonify_keys["hoge.1"]
      assert @instance.jsonify_keys["fuga"]
    end
  end

  sub_test_case "select" do
    test "object is hash" do
      @instance.add_key "test"
      object = {hoge: 1, fuga: "2"}
      @instance.select object

      assert_equal Set["test.hoge", "test.fuga"], output.keys.to_set
      assert_equal 1,   output["test.hoge"]
      assert_equal "2", output["test.fuga"]
    end

    test "object is array" do
      @instance.add_key "test"
      object = [:hoge, "fuga"]
      @instance.select object

      assert_equal Set["test.0", "test.1"], output.keys.to_set
      assert_equal :hoge,  output["test.0"]
      assert_equal "fuga", output["test.1"]
    end

    test "object is string" do
      @instance.add_key "test"
      object = "hoge"
      @instance.select object

      assert_equal Set["test"], output.keys.to_set
      assert_equal "hoge", output["test"]
    end

    test "object is number" do
      @instance.add_key "test"
      object = 12345
      @instance.select object

      assert_equal Set["test"], output.keys.to_set
      assert_equal 12345, output["test"]
    end

    test "object is nil" do
      @instance.add_key "test"
      object = nil
      @instance.select object

      assert_equal Set["test"], output.keys.to_set
      assert_equal nil, output["test"]
    end
  end

  sub_test_case "add_key" do
    test "add" do
      @instance.add_key "test"
      assert_equal ["test"], output_keys
      @instance.add_key 1
      assert_equal ["test", 1], output_keys
      @instance.add_key "hoge"
      assert_equal ["test", 1, "hoge"], output_keys
    end
  end

  sub_test_case "pop_key" do
    test "remove key by pop" do
      @instance.add_key "test"
      @instance.add_key 1
      @instance.add_key "hoge"
      assert_equal ["test", 1, "hoge"], output_keys

      @instance.pop_key
      assert_equal ["test", 1], output_keys

      @instance.pop_key
      assert_equal ["test"], output_keys

      @instance.pop_key
      assert_equal [], output_keys
    end

    test "without output_keys" do
      assert_nothing_raised do
        @instance.pop_key
      end
    end
  end

  sub_test_case "current_key" do
    test "with output_keys" do
      @instance.add_key "test"
      @instance.add_key 1
      assert_equal "test.1", @instance.current_key
    end

    test "without output_keys" do
      assert_equal "", @instance.current_key
    end

    test "for not default connector" do
      @instance = klass.new connector: "-"
      @instance.add_key "test"
      @instance.add_key 1
      assert_equal "test-1", @instance.current_key
    end
  end

  sub_test_case "acts_as_json" do
    test "with strinfied json" do
      value = {"hoge" => [ 10, 20 ], "fuga" => Date.new(2015, 1, 23)}.to_json
      assert_instance_of String, value
      result = @instance.acts_as_json value
      assert_equal Set["fuga", "hoge"], result.keys.to_set
      assert_equal [10, 20], result["hoge"]
      assert_equal Date.new(2015, 1, 23).to_s, result["fuga"]
    end

    test "with non json format string" do
      value = "hoge: [10, 20], fuga: 'undefined'"
      result = nil

      assert_raise JSON::ParserError do
        result = @instance.acts_as_json value
      end

      assert_nil result
    end

    test "with nil" do
      value = nil
      result = nil

      assert_raise JSON::ParserError do
        result = @instance.acts_as_json value
      end

      assert_nil result
    end

    test "with integer" do
      value = 123
      result = nil

      assert_raise JSON::ParserError do
        result = @instance.acts_as_json value
      end

      assert_nil result
    end

    test "with hash" do
      value = {"hoge" => [ 10, 20 ], "fuga" => Date.new(2015, 1, 23)}
      result = nil

      assert_raise JSON::ParserError do
        result = @instance.acts_as_json value
      end

      assert_nil result
    end

    test "with array" do
      value = [ 10, 20 ]
      result = nil

      assert_raise JSON::ParserError do
        result = @instance.acts_as_json value
      end

      assert_nil result
    end
  end

  sub_test_case "jsonify_keys?" do
    test "with no key" do
      @instance.jsonify_keys = {}
      @instance.output_keys = ["hoge", 0]
      assert !@instance.jsonify_key?
    end

    test "with key" do
      @instance.jsonify_keys = { "hoge.1" => true, "fuga" => false }

      @instance.output_keys = ["hoge", 1]
      assert @instance.jsonify_key?

      @instance.output_keys = ["fuga"]
      assert !@instance.jsonify_key?
    end
  end

  sub_test_case "jsonified!" do
    test "set false" do
      @instance.jsonify_keys = { "hoge.1" => true, "fuga" => false }

      @instance.output_keys = ["hoge", 1]
      @instance.jsonified!
      assert !@instance.jsonify_keys["hoge.1"]

      @instance.output_keys = ["fuga"]
      @instance.jsonified!
      assert !@instance.jsonify_keys["fuga"]

      @instance.output_keys = ["piyo"]
      @instance.jsonified!
      assert !@instance.jsonify_keys["piyo"]
    end
  end

  sub_test_case "init_jsonify_keys" do
    test "with array keys" do
      jsonify_keys = @instance.init_jsonify_keys ["hoge.1", "fuga"]
      assert_equal Set["fuga", "hoge.1"], jsonify_keys.keys.to_set
      assert jsonify_keys["hoge.1"]
      assert jsonify_keys["fuga"]
    end

    test "with empty keys" do
      jsonify_keys = @instance.init_jsonify_keys []
      assert jsonify_keys.keys.empty?
      assert_equal Hash.new, jsonify_keys
    end

    test "with nil" do
      jsonify_keys = @instance.init_jsonify_keys nil
      assert jsonify_keys.keys.empty?
      assert_equal Hash.new, jsonify_keys
    end
  end

  sub_test_case "update" do
    test "with current_key" do
      @instance.add_key "test"
      @instance.add_key 1
      @instance.update 12345

      assert_equal ["test.1"], output.keys
      assert_equal 12345, output["test.1"]
    end

    test "without current_key" do
      assert @instance.current_key.empty?
      @instance.update 12345

      assert_equal [], output.keys
    end

    test "with jsonify_keys" do
      @instance.jsonify_keys = @instance.init_jsonify_keys ["hoge.1", "fuga"]
      value = {"test" => [12345, 6789], "piyo" => nil}.to_json

      @instance.add_key "hoge"
      @instance.add_key 0
      @instance.update value
      assert_equal ["hoge.0"], output.keys
      assert_equal value, output["hoge.0"]

      @instance.pop_key
      @instance.pop_key
      @instance.add_key "hoge"
      @instance.add_key 1
      @instance.update value
      assert_equal Set["hoge.0", "hoge.1.piyo", "hoge.1.test.0", "hoge.1.test.1"], output.keys.to_set
      assert_equal value, output["hoge.0"]
      assert_equal 12345, output["hoge.1.test.0"]
      assert_equal 6789, output["hoge.1.test.1"]
      assert_equal nil, output["hoge.1.piyo"]

      @instance.pop_key
      @instance.pop_key
      @instance.add_key "fuga"
      @instance.update 987654321
      assert_equal Set["hoge.0", "hoge.1.piyo", "hoge.1.test.0", "hoge.1.test.1", "fuga"], output.keys.to_set
      assert_equal value, output["hoge.0"]
      assert_equal 12345, output["hoge.1.test.0"]
      assert_equal 6789, output["hoge.1.test.1"]
      assert_equal nil, output["hoge.1.piyo"]
      assert_equal 987654321, output["fuga"]
    end
  end

  sub_test_case "convert_hash" do
    test "hash is blank" do
      @instance.add_key "test"
      object = {}
      @instance.convert_hash object
      assert_equal ["test"], output.keys
      assert_equal nil, output["test"]
    end

    test "convert" do
      @instance.add_key "test"
      object = {"a" => "hoge", "b" => 1, "c" => {"hoge" => "fuga"}, "d" => [10, 20], "e" => nil}
      @instance.convert_hash object
      assert_equal Set["test.a", "test.b", "test.c.hoge", "test.d.0", "test.d.1", "test.e"], output.keys.to_set
      assert_equal "hoge", output["test.a"]
      assert_equal 1,      output["test.b"]
      assert_equal "fuga", output["test.c.hoge"]
      assert_equal 10,     output["test.d.0"]
      assert_equal 20,     output["test.d.1"]
      assert_equal nil,    output["test.e"]
    end
  end

  sub_test_case "convert_array" do
    test "array is empty" do
      @instance.add_key "test"
      object = []
      @instance.convert_array object
      assert_equal ["test"], output.keys
      assert_equal nil, output["test"]
    end

    test "convert" do
      @instance.add_key "test"
      object = ["hoge", 1, {"hoge" => "fuga"}, [10, 20], nil]
      @instance.convert_array object
      assert_equal Set["test.0", "test.1", "test.2.hoge", "test.3.0", "test.3.1", "test.4"], output.keys.to_set
      assert_equal "hoge", output["test.0"]
      assert_equal 1,      output["test.1"]
      assert_equal "fuga", output["test.2.hoge"]
      assert_equal 10,     output["test.3.0"]
      assert_equal 20,     output["test.3.1"]
      assert_equal nil,    output["test.4"]
    end
  end

  def output
    @instance.output
  end

  def output_keys
    @instance.output_keys
  end

  def klass
    Fluent::NestedHashFilter::NestedObject
  end
end
