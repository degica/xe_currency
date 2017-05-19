# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "xe_currency"
  spec.version       = "0.0.1"
  spec.authors       = ["Chris Salzberg"]
  spec.email         = ["csalzberg@degica.com"]

  spec.summary       = %q{Access XE currency rate data.}
  spec.homepage      = "https://github.com/degica/xe_currency"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.add_dependency "money", "~> 6.7"
  spec.add_dependency "nokogiri", "~> 1.7", ">= 1.7.2"

  spec.files =  Dir.glob("{lib,spec}/**/*")
  spec.files += %w(LICENSE.txt README.md)
  spec.files += %w(Rakefile xe_currency.gemspec)

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
