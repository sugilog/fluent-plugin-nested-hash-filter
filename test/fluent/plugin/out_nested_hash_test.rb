require "test_helper"
require "fluent/plugin/out_nested_hash"

class OutNestedHashTest < Test::Unit::TestCase
  include Fluent

  setup do
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  def create_driver config = "", tag = "test"
    driver = Fluent::Test::OutputTestDriver.new OutNestedHash, tag
    driver.configure config
  end

  def emit config, tag, messages
    driver = create_driver config, tag

    driver.run do
      messages.each do |message|
        driver.emit message
      end
    end

    driver
  end

  def emitted driver, index
    result = driver.emits[index]
    {tag: result[0], time: result[1], message: result[2]}
  end

  sub_test_case "configure" do
    test "check_default" do
      driver = create_driver "tag_prefix default"
      assert_equal "default", driver.instance.tag_prefix
      assert_equal nil, driver.instance.connector
      assert_equal [], driver.instance.acts_as_json
    end

    test "with tag_prefix" do
      driver = create_driver "tag_prefix filtered."
      assert_equal "filtered.", driver.instance.tag_prefix
      assert_equal [], driver.instance.acts_as_json
    end

    test "with connector" do
      driver = create_driver "tag_prefix default\nconnector -"
      assert_equal "default", driver.instance.tag_prefix
      assert_equal "-", driver.instance.connector
      assert_equal [], driver.instance.acts_as_json
    end

    test "with acts_as_json" do
      driver = create_driver "acts_as_json [\"hoge.1\", \"fuga\"]\ntag_prefix default"
      assert_equal "default", driver.instance.tag_prefix
      assert_equal nil, driver.instance.connector
      assert_equal ["hoge.1", "fuga"], driver.instance.acts_as_json
    end
  end

  sub_test_case "emit" do
    test "with valid record" do
      driver = emit "tag_prefix filtered.", "test", [
        {a: 1, b: {c: 2, d: {e: 3, f:4}, g: [10, 20, 30]}, h: [], i: {}},
        {a: {b: {c: 1, d: {e: 2, f:3}, g: [10, 20, 30]}, h: [], i: {}}}
      ]

      expect_message = {"a" => 1, "b.c" => 2, "b.d.e" => 3, "b.d.f" => 4, "b.g.0" => 10, "b.g.1" => 20, "b.g.2" => 30, "h" => nil, "i" => nil}
      result = emitted driver, 0
      assert_equal "filtered.test", result[:tag]
      assert_equal expect_message, result[:message]

      expect_message = {"a.b.c" => 1, "a.b.d.e" => 2, "a.b.d.f" => 3, "a.b.g.0" => 10, "a.b.g.1" => 20, "a.b.g.2" => 30, "a.h" => nil, "a.i" => nil}
      result = emitted driver, 1
      assert_equal "filtered.test", result[:tag]
      assert_equal expect_message, result[:message]
    end

    test "with connector" do
      driver = emit "tag_prefix filtered.\nconnector -", "test", [
        {a: 1, b: {c: 2, d: {e: 3, f:4}, g: [10, 20, 30]}, h: [], i: {}},
        {a: {b: {c: 1, d: {e: 2, f:3}, g: [10, 20, 30]}, h: [], i: {}}}
      ]

      expect_message = {"a" => 1, "b-c" => 2, "b-d-e" => 3, "b-d-f" => 4, "b-g-0" => 10, "b-g-1" => 20, "b-g-2" => 30, "h" => nil, "i" => nil}
      result = emitted driver, 0
      assert_equal "filtered.test", result[:tag]
      assert_equal expect_message, result[:message]

      expect_message = {"a-b-c" => 1, "a-b-d-e" => 2, "a-b-d-f" => 3, "a-b-g-0" => 10, "a-b-g-1" => 20, "a-b-g-2" => 30, "a-h" => nil, "a-i" => nil}
      result = emitted driver, 1
      assert_equal "filtered.test", result[:tag]
      assert_equal expect_message, result[:message]
    end

    test "with acts_as_json" do
      driver = emit "acts_as_json [\"a\",\"b.c\"]\ntag_prefix filtered.", "test", [
        {a: "[100, 200]", b: {c: '{"x": 1, "y": 2, "z": 3}', d: {e: 3, f:4}, g: [10, 20, 30]}, h: [], i: {}},
      ]

      expect_message = {"a.0" => 100, "a.1" => 200, "b.c.x" => 1, "b.c.y" => 2, "b.c.z" => 3, "b.d.e" => 3, "b.d.f" => 4, "b.g.0" => 10, "b.g.1" => 20, "b.g.2" => 30, "h" => nil, "i" => nil}
      result = emitted driver, 0
      assert_equal "filtered.test", result[:tag]
      assert_equal expect_message, result[:message]
    end

    test "with invalid record" do
      driver = emit "tag_prefix filtered.", "test", ["message", {hoge: 1, fuga: {"test0" => 2, "test1" => 3}}]

      expect_message = {}
      result = emitted driver, 0
      assert_equal expect_message, result[:message]

      expect_message = {"hoge" => 1, "fuga.test0" => 2, "fuga.test1" => 3}
      result = emitted driver, 1
      assert_equal "filtered.test", result[:tag]
      assert_equal expect_message, result[:message]
    end
  end
end
