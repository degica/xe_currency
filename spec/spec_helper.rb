$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "money/bank/xe_currency"

require "rspec"
require "webmock/rspec"
require "pry-byebug"

def fixture_path
  File.expand_path('fixtures', File.dirname(__FILE__))
end

def get_response(filename)
  file = File.open(File.join(fixture_path, filename))
  file.read
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end

Money.default_bank = Money::Bank::XeCurrency.new
I18n.available_locales = [:en]
