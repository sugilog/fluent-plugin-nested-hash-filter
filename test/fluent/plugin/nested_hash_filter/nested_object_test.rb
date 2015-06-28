require "test_helper"
require "fluent/plugin/nested_hash_filter/nested_object"

class NestedObjectTest < Test::Unit::TestCase
  setup do
    klass.init
  end

  sub_test_case "constants" do
    test "::CONNECTOR" do
      assert_equal ".", klass::CONNECTOR
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

  sub_test_case "select" do
    test "object is hash" do
      klass.add_key "test"
      object = {hoge: 1, fuga: "2"}
      klass.select object

      assert_equal Set["test.hoge", "test.fuga"], output.keys.to_set
      assert_equal 1,   output["test.hoge"]
      assert_equal "2", output["test.fuga"]
    end

    test "object is array" do
      klass.add_key "test"
      object = [:hoge, "fuga"]
      klass.select object

      assert_equal Set["test.0", "test.1"], output.keys.to_set
      assert_equal :hoge,  output["test.0"]
      assert_equal "fuga", output["test.1"]
    end

    test "object is string" do
      klass.add_key "test"
      object = "hoge"
      klass.select object

      assert_equal Set["test"], output.keys.to_set
      assert_equal "hoge", output["test"]
    end

    test "object is number" do
      klass.add_key "test"
      object = 12345
      klass.select object

      assert_equal Set["test"], output.keys.to_set
      assert_equal 12345, output["test"]
    end

    test "object is nil" do
      klass.add_key "test"
      object = nil
      klass.select object

      assert_equal Set["test"], output.keys.to_set
      assert_equal nil, output["test"]
    end
  end

  sub_test_case "add_key" do
    test "add" do
      klass.add_key "test"
      assert_equal ["test"], output_keys
      klass.add_key 1
      assert_equal ["test", 1], output_keys
      klass.add_key "hoge"
      assert_equal ["test", 1, "hoge"], output_keys
    end
  end

  sub_test_case "pop_key" do
    test "remove key by pop" do
      klass.add_key "test"
      klass.add_key 1
      klass.add_key "hoge"
      assert_equal ["test", 1, "hoge"], output_keys

      klass.pop_key
      assert_equal ["test", 1], output_keys

      klass.pop_key
      assert_equal ["test"], output_keys

      klass.pop_key
      assert_equal [], output_keys
    end

    test "without output_keys" do
      assert_nothing_raised do
        klass.pop_key
      end
    end
  end

  sub_test_case "current_key" do
    test "with output_keys" do
      klass.add_key "test"
      klass.add_key 1
      assert_equal "test.1", klass.current_key
    end

    test "without output_keys" do
      assert_equal "", klass.current_key
    end
  end

  sub_test_case "update" do
    test "with current_key" do
      klass.add_key "test"
      klass.add_key 1
      klass.update 12345

      assert_equal ["test.1"], output.keys
      assert_equal 12345, output["test.1"]
    end

    test "without current_key" do
      assert klass.current_key.empty?
      klass.update 12345

      assert_equal [], output.keys
    end
  end

  sub_test_case "convert_hash" do
    test "hash is blank" do
      klass.add_key "test"
      object = {}
      klass.convert_hash object
      assert_equal ["test"], output.keys
      assert_equal nil, output["test"]
    end

    test "convert" do
      klass.add_key "test"
      object = {"a" => "hoge", "b" => 1, "c" => {"hoge" => "fuga"}, "d" => [10, 20], "e" => nil}
      klass.convert_hash object
      assert_equal ["test.a", "test.b", "test.c.hoge", "test.d.0", "test.d.1", "test.e"], output.keys
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
      klass.add_key "test"
      object = []
      klass.convert_array object
      assert_equal ["test"], output.keys
      assert_equal nil, output["test"]
    end

    test "convert" do
      klass.add_key "test"
      object = ["hoge", 1, {"hoge" => "fuga"}, [10, 20], nil]
      klass.convert_array object
      assert_equal ["test.0", "test.1", "test.2.hoge", "test.3.0", "test.3.1", "test.4"], output.keys
      assert_equal "hoge", output["test.0"]
      assert_equal 1,      output["test.1"]
      assert_equal "fuga", output["test.2.hoge"]
      assert_equal 10,     output["test.3.0"]
      assert_equal 20,     output["test.3.1"]
      assert_equal nil,    output["test.4"]
    end
  end

  def output
    klass.instance_variable_get :@output
  end

  def output_keys
    klass.instance_variable_get :@output_keys
  end

  def klass
    Fluent::NestedHashFilter::NestedObject
  end
end
