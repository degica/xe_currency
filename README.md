# XeCurrency

This gem extends Money::Bank::VariableExchange with Money::Bank::XeCurrency and
gives you access to the current rates from the XE currency converter.

## Usage

```ruby
require 'money'
require 'money/bank/xe_currency'

# (optional)
# set the seconds after than the current rates are automatically expired
# by default, they never expire
Money::Bank::XeCurrency.ttl_in_seconds = 86400

# set default bank to instance of XeCurrency
Money.default_bank =
  Money::Bank::XeCurrency.new(
    Money::RatesStore::Memory.new,
    account_api_id: '<Account API ID>',
    account_api_key: '<Account API Key>'
  )

# create a new money object, and use the standard #exchange_to method
money = Money.new(1_00, "USD") # amount is in cents
money.exchange_to(:EUR)

# or install and use the 'monetize' gem
require 'monetize'
money = 1.to_money(:USD)
money.exchange_to(:EUR)
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
