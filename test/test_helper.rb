$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require "test/unit"
require "fluent/test"
require "fluent/log"
require "fluent/load"

class Test::Unit::TestCase
end
