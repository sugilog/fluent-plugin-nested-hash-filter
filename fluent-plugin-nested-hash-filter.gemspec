# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-nested-hash-filter"
  spec.version       = "0.0.1"
  spec.authors       = ["sugilog"]
  spec.email         = ["sugilog@gmail.com"]

  spec.summary       = %q{Fluent Plugin for converting nested hash into flatten key-value pair.}
  spec.description   = %q{Fluent Plugin for converting nested hash into flatten key-value pair.}
  spec.homepage      = "https://github.com/sugilog/fluent-plugin-nested-hash-filter"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "fluentd"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-test"
end
