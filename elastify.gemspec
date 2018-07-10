# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elastify/version'

Gem::Specification.new do |spec|
  spec.name          = "elastify"
  spec.version       = Elastify::VERSION
  spec.authors       = ["Bruno Bortolotti Ribeiro"]
  spec.email         = ["brunobortolotti@icloud.com"]

  spec.summary       = %q{A gem to help with ActiveRecord-ElasticSeach integration}
  spec.description   = %q{A gem to help with ActiveRecord-ElasticSeach integration}
  spec.homepage      = "https://github.com/brunobortolotti/elastify.git"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", ">= 3.0.5"
  spec.add_runtime_dependency "httparty", ">= 0.6.0"
  spec.add_runtime_dependency "backgrounded", ">= 2.0.0"
  spec.add_runtime_dependency "multi_json", ">= 1.0.0"
  spec.add_runtime_dependency "rest-client", ["~> 2.0", ">= 2.0.1"]
  
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "shoulda", "2.11.3"
  spec.add_development_dependency "mocha", "0.10.0"
  spec.add_development_dependency "pry", "0.9.9.3"
end
