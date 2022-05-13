# frozen_string_literal: true

require 'spec_helper'

describe Money::Bank::XeCurrency do
  before do
    Money.default_bank = Money::Bank::XeCurrency.new(
      Money::RatesStore::Memory.new,
      account_api_id: 'fake',
      account_api_key: 'fake'
    )
  end

  it 'converts rates' do
    stub_request(:get, 'https://xecdapi.xe.com/v1/convert_from.json?from=JPY&to=USD')
      .to_return(body: get_response('jpy_to_usd.json'))
    stub_request(:get, 'https://xecdapi.xe.com/v1/convert_from.json?from=USD&to=JPY')
      .to_return(body: get_response('usd_to_jpy.json'))

    money = Money.new(1_00, 'JPY')
    expect(money.exchange_to(:USD).to_s).to eq('0.78')

    money = Money.new(1_00, 'USD')
    expect(money.exchange_to(:JPY).to_s).to eq('129')
  end

  it 'raises an error with a given message' do
    stub_request(:get, 'https://xecdapi.xe.com/v1/convert_from.json?from=JPY&to=USD')
      .to_return(status: 401, body: get_response('error_bad_credentials.json'))

    money = Money.new(1_00, 'JPY')
    expect { money.exchange_to(:USD) }.to raise_error(Money::Bank::XeCurrency::XeCurrencyFetchError, 'Bad credentials')
  end
end
