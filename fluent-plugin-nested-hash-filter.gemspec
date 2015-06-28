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

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "fluentd"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-test"
end
