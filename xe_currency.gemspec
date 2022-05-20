# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xe_currency/version'

Gem::Specification.new do |spec|
  spec.name          = 'xe_currency'
  spec.version       = XeCurrency::VERSION
  spec.authors       = ['Degica', 'Chris Salzberg']
  spec.email         = ['dev@degica.com']

  spec.summary       = 'Access XE currency rate data.'
  spec.homepage      = 'https://github.com/degica/xe_currency'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
  #    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.add_dependency 'money', '~> 6.13'

  spec.files =  Dir.glob('{lib,spec}/**/*')
  spec.files += %w[LICENSE.txt README.md]
  spec.files += %w[Rakefile xe_currency.gemspec]

  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'rubocop', '~> 1.29'
  spec.add_development_dependency 'webmock'
end
