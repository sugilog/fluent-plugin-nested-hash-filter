require "test_helper"
require "fluent/plugin/filter_nested_hash"
require "fluent/test/driver/filter"

class FilterNestedHashTest < Test::Unit::TestCase
  include Fluent

  setup do
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  def create_driver config = ""
    driver = Test::Driver::Filter.new Plugin::FilterNestedHash
    driver.configure config
  end

  def emit config, messages
    driver = create_driver config

    driver.run(default_tag: 'test') do
      messages.each do |message|
        message = [message] if message.is_a?(String)
        driver.feed message
      end
    end

    driver
  end

  def filtered driver, index
    result = driver.filtered[index]
    {time: result[0], message: result[1]}
  end

  sub_test_case "configure" do
    test "check default" do
      driver = create_driver "default"
      assert_equal nil, driver.instance.connector
      assert_equal [], driver.instance.acts_as_json
    end

    test "with connector" do
      driver = create_driver "connector -"
      assert_equal "-", driver.instance.connector
      assert_equal [], driver.instance.acts_as_json
    end

    test "with acts_as_json" do
      driver = create_driver "acts_as_json [\"hoge.1\", \"fuga\"]"
      assert_equal nil, driver.instance.connector
      assert_equal ["hoge.1", "fuga"], driver.instance.acts_as_json
    end
  end

  sub_test_case "filter" do
    test "with valid record" do
      driver = emit "", [
        {a: 1, b: {c: 2, d: {e: 3, f:4}, g: [10, 20, 30]}, h: [], i: {}},
        {a: {b: {c: 1, d: {e: 2, f:3}, g: [10, 20, 30]}, h: [], i: {}}}
      ]

      expect_message = {"a" => 1, "b.c" => 2, "b.d.e" => 3, "b.d.f" => 4, "b.g.0" => 10, "b.g.1" => 20, "b.g.2" => 30, "h" => nil, "i" => nil}
      result = filtered driver, 0
      assert_equal expect_message, result[:message]

      expect_message = {"a.b.c" => 1, "a.b.d.e" => 2, "a.b.d.f" => 3, "a.b.g.0" => 10, "a.b.g.1" => 20, "a.b.g.2" => 30, "a.h" => nil, "a.i" => nil}
      result = filtered driver, 1
      assert_equal expect_message, result[:message]
    end

    test "with connector" do
      driver = emit "connector -", [
        {a: 1, b: {c: 2, d: {e: 3, f:4}, g: [10, 20, 30]}, h: [], i: {}},
        {a: {b: {c: 1, d: {e: 2, f:3}, g: [10, 20, 30]}, h: [], i: {}}}
      ]

      expect_message = {"a" => 1, "b-c" => 2, "b-d-e" => 3, "b-d-f" => 4, "b-g-0" => 10, "b-g-1" => 20, "b-g-2" => 30, "h" => nil, "i" => nil}
      result = filtered driver, 0
      assert_equal expect_message, result[:message]

      expect_message = {"a-b-c" => 1, "a-b-d-e" => 2, "a-b-d-f" => 3, "a-b-g-0" => 10, "a-b-g-1" => 20, "a-b-g-2" => 30, "a-h" => nil, "a-i" => nil}
      result = filtered driver, 1
      assert_equal expect_message, result[:message]
    end

    test "with acts_as_json" do
      driver = emit "acts_as_json [\"a\",\"b.c\"]", [
        {a: "[100, 200]", b: {c: '{"x": 1, "y": 2, "z": 3}', d: {e: 3, f:4}, g: [10, 20, 30]}, h: [], i: {}},
      ]

      expect_message = {"a.0" => 100, "a.1" => 200, "b.c.x" => 1, "b.c.y" => 2, "b.c.z" => 3, "b.d.e" => 3, "b.d.f" => 4, "b.g.0" => 10, "b.g.1" => 20, "b.g.2" => 30, "h" => nil, "i" => nil}
      result = filtered driver, 0
      assert_equal expect_message, result[:message]
    end

    test "with invalid record" do
      driver = emit "", ["message", {hoge: 1, fuga: {"test0" => 2, "test1" => 3}}]

      expect_message = {}
      result = filtered driver, 0
      assert_equal expect_message, result[:message]

      expect_message = {"hoge" => 1, "fuga.test0" => 2, "fuga.test1" => 3}
      result = filtered driver, 1
      assert_equal expect_message, result[:message]
    end
  end
end
