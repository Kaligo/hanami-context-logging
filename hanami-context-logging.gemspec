require_relative "lib/hanami_context_logging/version"

Gem::Specification.new do |spec|
  spec.name          = "hanami-context-logging"
  spec.version       = HanamiContextLogging::VERSION
  spec.authors       = ["sswander"]
  spec.email         = ["leonardosyahputra@yahoo.com"]

  spec.summary       = "Context logging for Hanami::Logger"
  spec.description   = "Simple context logger to be used together with Hanami::Logger"
  spec.homepage      = "https://github.com/sswander/hanami-context-logger"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "hanami-utils", "~> 1.3"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
