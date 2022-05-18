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
      uri = build_uri(from, to)
      res = get(uri)
      data = raise_or_return(res)
      extract_rate(data)
    end

    private

    ##
    # Build a URI for the given arguments.
    #
    # @param [String] from The currency to convert from.
    # @param [String] to The currency to convert to.
    #
    # @return [URI::HTTPS]
    def build_uri(from, to)
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
    #
    # @return [BigDecimal]
    def extract_rate(data)
      rate = JSON.parse(data)['to'][0]['mid']
      BigDecimal(rate.to_s)
    rescue StandardError
      raise FetchError, 'Error parsing rates or adding rates to store'
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
