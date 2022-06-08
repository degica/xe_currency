# frozen_string_literal: true

module XeCurrency
  class Client
    attr_reader :account_api_id, :account_api_key

    # Raised when there is an unexpected error in extracting exchange rates
    # from Xe Finance Calculator
    class FetchError < StandardError; end

    SERVICE_HOST = 'xecdapi.xe.com'
    SERVICE_PATH = '/v1/convert_from.json'

    def initialize(account_api_id:, account_api_key:)
      @account_api_id = account_api_id
      @account_api_key = account_api_key
    end

    ##
    # Queries for the requested rate and returns it.
    #
    # @param [String] from Currency to convert from
    # @param [String] to Currency to convert to
    #
    # @return [BigDecimal] The requested rate.
    # @raise [FetchError]
    def fetch_rate(from, to)
      rates = fetch_rates(from, [to])
      rates[to]
    end

    ##
    # Queries for the requested rates and returns them.
    #
    # @param [String] from Currency to convert from
    # @param [Array(String)] to Currencies to convert to
    #
    # @return [Array(BigDecimal)] The requested rates.
    # @raise [FetchError]
    def fetch_rates(from, to)
      uri = build_uri(from, to)
      res = get(uri)
      data = raise_or_return(res)
      extract_rates(data, to)
    end

    private

    ##
    # Build a URI for the given arguments.
    #
    # @param [String] from The currency to convert from.
    # @param [Array(String)] to The currencies to convert to.
    #
    # @return [URI::HTTPS]
    def build_uri(from, to)
      to = to.join(',')
      URI::HTTPS.build(
        host: SERVICE_HOST,
        path: SERVICE_PATH,
        query: [
          "from=#{from}",
          "to=#{to}"
        ].join('&')
      )
    end

    # Send a HTTPS Get request
    #
    # @param [URI::HTTPS]
    # @return [Net::HTTPResponse]
    def get(uri)
      req = Net::HTTP::Get.new("#{uri.path}?#{uri.query}")
      req.basic_auth(account_api_id, account_api_key)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      https.request(req)
    end

    ##
    # Takes the response from Xe and extract the rate.
    #
    # @param [String] data The xe rate string to decode.
    # @param [Array(String)] to The currencies convert to.
    #
    # @return [Hash{String => BigDecimal}]
    def extract_rates(data, to)
      json = JSON.parse(data)
      rates = to.map do |currency|
        rate = json['to'].find { |t| t['quotecurrency'] == currency }
        [currency, BigDecimal(rate['mid'].to_s)]
      end
      Hash[*rates.flatten]
    rescue StandardError => e
      raise FetchError, e.message
    end

    # @return [Hash]
    # @raise [FetchError]
    def raise_or_return(response)
      return response.body if response.code == '200'

      rsp_body = JSON.parse(response.body)
      rsp_message = rsp_body.fetch('message')

      raise FetchError, rsp_message
    end
  end
end
