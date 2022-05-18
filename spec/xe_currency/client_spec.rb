# frozen_string_literal: true

require 'spec_helper'

describe XeCurrency::Client do
  let(:client) do
    described_class.new(
      account_api_id: 'fake',
      account_api_key: 'fake'
    )
  end

  it 'fetches a rate' do
    stub_request(:get, 'https://xecdapi.xe.com/v1/convert_from.json?from=JPY&to=USD')
      .to_return(body: get_response('jpy_to_usd.json'))
    stub_request(:get, 'https://xecdapi.xe.com/v1/convert_from.json?from=USD&to=JPY')
      .to_return(body: get_response('usd_to_jpy.json'))

    expect(client.fetch_rate('JPY', 'USD')).to eq(BigDecimal('0.0077759754'))
    expect(client.fetch_rate('USD', 'JPY')).to eq(BigDecimal('128.6012304362'))
  end

  it 'raises an error with a given message' do
    stub_request(:get, 'https://xecdapi.xe.com/v1/convert_from.json?from=JPY&to=USD')
      .to_return(status: 401, body: get_response('error_bad_credentials.json'))

    expect { client.fetch_rate('JPY', 'USD') }.to raise_error(XeCurrency::Client::FetchError, 'Bad credentials')
  end
end
