# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'xe_currency'
require 'rspec'
require 'webmock/rspec'
require 'pry-byebug'

def fixture_path
  File.expand_path('fixtures', File.dirname(__FILE__))
end

def get_response(filename)
  file = File.open(File.join(fixture_path, filename))
  file.read
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end

Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
Money.locale_backend = :i18n
I18n.available_locales = [:en]
