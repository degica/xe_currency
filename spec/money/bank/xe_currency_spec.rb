# frozen_string_literal: true

require 'spec_helper'

describe Money::Bank::XeCurrency do
  let(:client) { instance_double(::XeCurrency::Client) }

  before do
    allow(::XeCurrency::Client).to receive(:new).and_return(client)

    Money.default_bank = Money::Bank::XeCurrency.new(
      Money::RatesStore::Memory.new,
      account_api_id: 'fake',
      account_api_key: 'fake'
    )
  end

  it 'converts rates' do
    expect(client).to receive(:fetch_rate).with('JPY', 'USD').and_return(BigDecimal('0.0077759754'))
    expect(client).to receive(:fetch_rate).with('USD', 'JPY').and_return(BigDecimal('128.6012304362'))

    money = Money.new(1_00, 'JPY')
    expect(money.exchange_to(:USD).to_s).to eq('0.78')

    money = Money.new(1_00, 'USD')
    expect(money.exchange_to(:JPY).to_s).to eq('129')
  end

  it 'raises an error with a given message' do
    expect(client).to receive(:fetch_rate).and_raise(::XeCurrency::Client::FetchError, 'Bad credentials')

    money = Money.new(1_00, 'JPY')
    expect { money.exchange_to(:USD) }.to raise_error(Money::Bank::XeCurrency::XeCurrencyFetchError, 'Bad credentials')
  end
end
