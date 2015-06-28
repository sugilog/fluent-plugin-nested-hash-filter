require "test_helper"
require "fluent/plugin/filter_nested_hash"

class FilterNestedHashTest < Test::Unit::TestCase
  include Fluent

  setup do
    Fluent::Test.setup
    @time = Fluent::Engine.now
  end

  def create_driver config = ""
    driver = Test::FilterTestDriver.new FilterNestedHash
    driver.configure config, true
  end

  def emit config, messages
    driver = create_driver config

    driver.run do
      messages.each do |message|
        driver.emit message, @time
      end
    end.filtered
    
    driver
  end

  def filtered driver, index
    result = driver.filtered_as_array[index]
    {tag: result[0], time: result[1], message: result[2]}
  end

  sub_test_case "configure" do
    test "check default" do
      assert_nothing_raised do
        create_driver "default"
      end
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
