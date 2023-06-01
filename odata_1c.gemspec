
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "odata_1c/version"

Gem::Specification.new do |spec|
  spec.name          = "odata_1c"
  spec.version       = Odata1c::VERSION
  spec.authors       = ["CavemaN21"]
  spec.email         = ["kotkidach@naumen.ru"]
  spec.summary       = %q{This is a short summary}
  spec.description   = %q{This is a long description}
  # spec.homepage      = "Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.8"

  spec.add_dependency 'addressable', '~> 2.5', '>= 2.5.2'
  spec.add_dependency 'nokogiri', '~> 1.5', '>= 1.5.0'
  spec.add_dependency 'rest-client', '~> 2.0.2', '>= 2.0.2'
  spec.add_dependency 'webmock', '~> 3.4', '>= 3.4.2'
  spec.add_dependency 'activesupport', '> 5.0'
end
